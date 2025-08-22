extends CharacterBody2D

@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
@export var speed = 150;
@export var laser: PackedScene;
@export var ranged_unit = false;
var max_speed = 150;
var attack_rang = 70;

var targetRadius = 10;
var av = Vector2.ZERO;
var avoidWeight = 0.1;

##工人职业

var jobAttack = false;
var jobAttackUnit = false;

var target_id = null;
var targetMiddleOfEnemy = null;

var ableToShoot = true;
var new_id;

var health = 10;

var selected = false:
	set = setSelected;

var target = null:
	set = setTarget;

func setSelected(value):
	selected = value;
	if selected:
		$Body/BackSprite.visible = true;
		Global.workerSelected = true;
	else:
		$Body/BackSprite.visible = false;
		Global.workerSelected = false;

func setTarget(value):
	target = value;

func avoid():
	var result = Vector2.ZERO;
	var neighbors = $Area2D.get_overlapping_bodies();
	if neighbors:
		for n in neighbors:
			result += n.position.direction_to(position);
		result /= neighbors.size();
	return result.normalized();

func onNavigationAgent2dVelocityComputed(safeVelocity: Vector2):
	velocity = safeVelocity;

func makePath():
	if target != null:
		navAgent.target_position = target;

func moveTowardTarget():
	velocity = Vector2.ZERO;
	if target != null:
		velocity = position.direction_to(target);
		var dir = to_local(navAgent.get_next_path_position()).normalized();
		velocity = dir * speed;
		if position.distance_to(target) <= targetRadius:
			target = null;
	av = avoid();
	velocity = (velocity + av * avoidWeight).normalized() * speed;

	if navAgent.avoidance_enabled == true:
		navAgent.set_velocity(velocity);
	else:
		onNavigationAgent2dVelocityComputed(velocity);
	
	move_and_slide();
	var nextPathPosition = navAgent.get_next_path_position();
	
func _ready() -> void:
	Global.goodUnit += 1;
	Global.populationCount += 1;

	var characters = "abcdefghijklmnopqrstuvwsyz";
	new_id = Global.generateId(characters, 10);
	add_to_group("unit");

	if ranged_unit == true:
		max_speed = 75;
		attack_rang = 150;


func _physics_process(delta: float) -> void:
	makePath();
	moveTowardTarget();

	if selected == true and Global.newWorkerTarget != null:
		turnOffAllJobs();
		target = Global.newWorkerTarget;
		if Global.newWorkerTargetJob == "attack_unit":
			jobAttack = true;
			jobAttackUnit = true;
			target_id = Global.newWorkerTargetId;
		if Global.newWorkerTargetJob == "attack_building":
			jobAttack = true;
			jobAttackUnit = false;
			target_id = Global.newWorkerTargetId;
		if Global.newWorkerTargetType == "tile":
			findClosestSideOfTile();
		selected = false;

	if velocity != Vector2(0, 0):
		$Body.look_at($NavigationAgent2D.get_next_path_position())

	if jobAttack == true and target != null:
		var distanceToEnemy = (target - global_position).length()
		if distanceToEnemy <= attack_rang:
			$Body.look_at(targetMiddleOfEnemy)
			speed = 0
			if ableToShoot == true:
				ableToShoot = false;
				$TimerShoot.start();
				var newLaser = laser.instantiate();
				newLaser.is_good_laser = true;
				add_sibling(newLaser);
				newLaser.position = $Body.global_position
				newLaser.look_at(targetMiddleOfEnemy);
				newLaser.owner_id = new_id;
			var allEnemy = get_tree().get_nodes_in_group("enemy")
			var foundTargetEnemy = false;
			for enemy in allEnemy:
				if enemy.new_id == target_id:
					target = enemy.position;
					targetMiddleOfEnemy = target;
					if jobAttackUnit == false:
						findClosestSideOfTile();
					foundTargetEnemy = true;
			if foundTargetEnemy == false:
				jobAttack = false;
				target = null;
				target_id = null;
				turnOffAllJobs();
		else:
			var allEnemy = get_tree().get_nodes_in_group("enemy")
			var foundTargetEnemy = false;
			for enemy in allEnemy:
				if enemy.new_id == target_id:
					target = enemy.position;
					targetMiddleOfEnemy = target;
					if jobAttackUnit == false:
						findClosestSideOfTile();
					foundTargetEnemy = true;
			if foundTargetEnemy == false:
				jobAttack = false;
				target = null;
				target_id = null;
				turnOffAllJobs();
			speed = max_speed;

	if jobAttack == false and target == null:
		var all_units = get_tree().get_nodes_in_group("enemy");
		for unit in all_units:
			var distance_to_unit = (unit.position - self.global_position).length();
			if distance_to_unit <= 150 and target_id == null:
				target_id = unit.new_id;
				jobAttack = true;
				targetMiddleOfEnemy = unit.position;
				target = unit.position;
				if unit.i_am_building == true:
					findClosestSideOfTile();
				else:
					jobAttackUnit = true;

	$ProgressBar.value = health;

	if health <= 0:
		Global.enemyUnit -= 1;
		Global.populationCount -= 1;
		queue_free();

## 找到瓦片边缘
func findClosestSideOfTile():
	if target != null and target.x < self.position.x and target.y < self.position.y:
		target.x = target.x + 40;
		target.y = target.y + 40;
	elif target != null and target.x < self.position.x and target.y > self.position.y:
		target.x = target.x + 40;
		target.y = target.y - 40;
	elif  target != null and target.x > self.position.x and target.y < self.position.y:
		target.x = target.x - 40;
		target.y = target.y + 40;
	elif  target != null and target.x > self.position.x and target.y > self.position.y:
		target.x = target.x - 40;
		target.y = target.y - 40;


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_laser"):
		health -= 1;
		if target_id != area.owner_id:
			turnOffAllJobs();
			jobAttack = true;
			jobAttackUnit = true;
			target_id = area.owner_id;
			$Body.look_at(area.position)
			var allEnemy = get_tree().get_nodes_in_group("enemy")
			for enemy in allEnemy:
				if enemy.new_id == target_id:
					target = enemy.position;
					targetMiddleOfEnemy = target;
		area.queue_free()

## 找到最近的资源放置点
func findClosestDropOffSpot():
	var lowestDistance = INF;
	var closestDropOffs;
	var allDropOff;
	allDropOff = get_tree().get_nodes_in_group("town_center")
	for dropOff in allDropOff:
		var distance = dropOff.global_position.distance_to(position);
		if distance < lowestDistance:
			closestDropOffs = dropOff.position;
			lowestDistance = distance;
			target = closestDropOffs;

## 关闭所有Job
func turnOffAllJobs():
	target_id = null;
	jobAttack = false;
	jobAttackUnit = false;
	speed = max_speed;

func _on_timer_shoot_timeout() -> void:
	ableToShoot = true;

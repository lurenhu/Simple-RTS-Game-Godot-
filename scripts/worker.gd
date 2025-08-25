extends CharacterBody2D

@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
@export var speed = 150;
@export var laser: PackedScene;

var targetRadius = 10;
var av = Vector2.ZERO;
var avoidWeight = 0.1;

##工人职业

var jobBuilding = false;
var jobCuttingWood = false;
var jobMiningGold = false;
var jobFarmingFarm = false;
var jobAttack = false;
var jobAttackUnit = false;

var usingWorkerTools = false;
var targetId = null;
var targetMiddleOfEnemy = null;

var woodGather = 0;
var goldGather = 0;
var foodGather = 0;

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

func _physics_process(delta: float) -> void:
	makePath();
	moveTowardTarget();

	if selected == true and Global.newWorkerTarget != null:
		turnOffAllJobs();
		target = Global.newWorkerTarget;
		if Global.newWorkerTargetJob == Global.JOB.building:
			jobAttack = false;
			jobAttackUnit = false;
			jobBuilding = true;
			jobCuttingWood = false;
			jobFarmingFarm = false;
			jobMiningGold = false;
			targetId = Global.newWorkerTargetId;
		if Global.newWorkerTargetJob == Global.JOB.chop_wood:
			jobAttack = false;
			jobAttackUnit = false;
			jobBuilding = false;
			jobCuttingWood = true;
			jobFarmingFarm = false;
			jobMiningGold = false;
			targetId = Global.newWorkerTargetId;
		if Global.newWorkerTargetJob == Global.JOB.mine_gold:
			jobAttack = false;
			jobAttackUnit = false;
			jobBuilding = false;
			jobCuttingWood = false;
			jobFarmingFarm = false;
			jobMiningGold = true;
			targetId = Global.newWorkerTargetId;
		if Global.newWorkerTargetJob == Global.JOB.farm:
			jobAttack = false;
			jobAttackUnit = false;
			jobBuilding = false;
			jobCuttingWood = false;
			jobFarmingFarm = true;
			jobMiningGold = false;
			targetId = Global.newWorkerTargetId;
		if Global.newWorkerTargetJob == Global.JOB.attack_unit:
			jobAttack = true;
			jobAttackUnit = true;
			jobBuilding = false;
			jobCuttingWood = false;
			jobFarmingFarm = false;
			jobMiningGold = false;
			targetId = Global.newWorkerTargetId;
		if Global.newWorkerTargetJob == Global.JOB.attack_building:
			jobAttack = true;
			jobAttackUnit = false;
			jobBuilding = false;
			jobCuttingWood = false;
			jobFarmingFarm = false;
			jobMiningGold = false;
			targetId = Global.newWorkerTargetId;
		if Global.newWorkerTargetType == "tile" and jobFarmingFarm == false and jobAttack == false:
			findClosestSideOfTile();
		selected = false;

	if usingWorkerTools == true:
		speed = 0;
		$AnimationPlayer.play("use_tool");
		await $AnimationPlayer.animation_finished;
		if jobCuttingWood == true or jobMiningGold == true or jobFarmingFarm == true:
			findClosestDropOffSpot();
			findClosestSideOfTile();
			usingWorkerTools = false;
		speed = 150;

	if (jobCuttingWood == true or jobMiningGold == true or jobFarmingFarm == true) and $TimerStillToolLong.time_left == 0 and velocity == Vector2(0, 0) and target == null:
		usingWorkerTools = false;
		findClosestTargetForJob();
		resetStandStillTime();

	checkIfNoMoreResourcesForJob();

	if velocity != Vector2(0, 0):
		$Body.look_at($NavigationAgent2D.get_next_path_position())

	if jobAttack == true and target != null:
		var distanceToEnemy = (target - global_position).length()
		if distanceToEnemy <= 70:
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
				if enemy.new_id == targetId:
					target = enemy.position;
					targetMiddleOfEnemy = target;
					if jobAttackUnit == false:
						findClosestSideOfTile();
					foundTargetEnemy = true;
			if foundTargetEnemy == false:
				jobAttack = false;
				target = null;
				targetId = null;
				turnOffAllJobs();
		else:
			var allEnemy = get_tree().get_nodes_in_group("enemy")
			var foundTargetEnemy = false;
			for enemy in allEnemy:
				if enemy.new_id == targetId:
					target = enemy.position;
					targetMiddleOfEnemy = target;
					findClosestSideOfTile();
					foundTargetEnemy = true;
			if foundTargetEnemy == false:
				jobAttack = false;
				target = null;
				targetId = null;
				turnOffAllJobs();
			speed = 150;

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
	if area.is_in_group("unbuilt_building") and jobBuilding and area.new_id == targetId:
		usingWorkerTools = true;
		$Body.look_at(area.position);
	if area.is_in_group("built_building") and jobBuilding == true:
		usingWorkerTools = false;
		findClosestTargetForJob()
		resetStandStillTime()
	if area.is_in_group("tree") and jobCuttingWood == true and area.new_id == targetId:
		usingWorkerTools = true;
		$Body.look_at(area.position)
	if area.is_in_group("gold") and jobMiningGold == true and area.new_id == targetId:
		usingWorkerTools = true;
		$Body.look_at(area.position);
	if area.is_in_group("farm") and jobFarmingFarm == true and area.new_id == targetId:
		usingWorkerTools = true;
		$Body.look_at(area.position);
	if area.is_in_group("town_center") and (jobCuttingWood == true or jobMiningGold == true or jobFarmingFarm == true):
		Global.woodCount += woodGather;
		Global.goldCount += goldGather;
		Global.foodCount += foodGather;

		woodGather = 0;
		goldGather = 0;
		foodGather = 0;
		$Body.look_at(area.position)
		goBackToTheResources();
	if area.is_in_group("enemy_laser"):
		health -= 1;
		if targetId != area.owner_id:
			turnOffAllJobs();
			jobAttack = true;
			jobAttackUnit = true;
			targetId = area.owner_id;
			$Body.look_at(area.position)
			var allEnemy = get_tree().get_nodes_in_group("enemy")
			for enemy in allEnemy:
				if enemy.new_id == targetId:
					target = enemy.position;
					targetMiddleOfEnemy = target;
		area.queue_free()

func resetStandStillTime():
	$TimerStillToolLong.start()

## 找到最近的(同类目标)目标点
func findClosestTargetForJob():
	var lowestDistance = INF;
	var closestJob;
	var allJob;

	if jobBuilding == true:
		allJob = get_tree().get_nodes_in_group("unbuilt_building")
	if jobCuttingWood == true:
		allJob = get_tree().get_nodes_in_group("tree")
	if jobMiningGold == true:
		allJob = get_tree().get_nodes_in_group("gold")
	if jobFarmingFarm == true:
		allJob = get_tree().get_nodes_in_group("farm")
	for job in allJob:
		var distance = job.global_position.distance_to(position);
		if distance < lowestDistance:
			closestJob = job.position;
			lowestDistance = distance;
			targetId = job.new_id;
			target = closestJob;
			if jobFarmingFarm == false:
				findClosestSideOfTile()

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

## 返回原先的资源点
func goBackToTheResources():
	var lowestDistance = INF;
	var allReources;
	if jobCuttingWood == true:
		allReources = get_tree().get_nodes_in_group("tree")
	if jobMiningGold == true:
		allReources = get_tree().get_nodes_in_group("gold")
	if jobFarmingFarm == true:
		allReources = get_tree().get_nodes_in_group("farm")
	var foundResourceWithId = false;
	for resource in allReources:
		var distance = resource.global_position.distance_to(position);
		if resource.new_id == targetId:
			target = resource.position
			foundResourceWithId = true;
			if jobFarmingFarm == false:
				findClosestSideOfTile();

	if foundResourceWithId == false:
		targetId = null;
		target = null;
		findClosestTargetForJob();

## 关闭所有Job
func turnOffAllJobs():
	targetId = null;
	jobAttack = false;
	jobAttackUnit = false;
	jobCuttingWood = false;
	jobMiningGold = false;
	jobFarmingFarm = false;
	jobBuilding = false;
	usingWorkerTools = false;
	speed = 150;

## 检查是否还有(同类)资源
func checkIfNoMoreResourcesForJob():
	var lowestDistance = INF;
	var allReources;
	if jobBuilding == true:
		allReources = get_tree().get_nodes_in_group("unbuilt.building");
	if jobCuttingWood == true:
		allReources = get_tree().get_nodes_in_group("tree")
	if jobMiningGold == true:
		allReources = get_tree().get_nodes_in_group("gold")
	if jobFarmingFarm == true:
		allReources = get_tree().get_nodes_in_group("farm")
	if jobAttack == true:
		allReources = get_tree().get_nodes_in_group("enemy")
	if allReources == null:
		turnOffAllJobs();


func _on_timer_shoot_timeout() -> void:
	ableToShoot = true;

extends CharacterBody2D

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D;
@export var speed = 150;
@export var laser : PackedScene;

var target_id = null;
var target_middle_enemy_building = null;
var target_radius = 10;
var av = Vector2.ZERO;
var avoid_weight = 0.1;

var atttacking_unit = false;
var able_to_shoot = true;
var new_id;
var i_am_building = false;

var health = 10;

@export var is_ranged_unit = false;
var attack_rang = 70;
var unit_speed = 150

var target = null:
	set = setTarget;

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
		nav_agent.target_position = target;

func moveTowardTarget():
	velocity = Vector2.ZERO;
	if target != null:
		velocity = position.direction_to(target);
		var dir = to_local(nav_agent.get_next_path_position()).normalized();
		velocity = dir * speed;
		if position.distance_to(target) <= target_radius:
			target = null;
	av = avoid();
	velocity = (velocity + av * avoid_weight).normalized() * speed;

	if nav_agent.avoidance_enabled == true:
		nav_agent.set_velocity(velocity);
	else:
		onNavigationAgent2dVelocityComputed(velocity);
	
	move_and_slide();
	var nextPathPosition = nav_agent.get_next_path_position();


func _ready() -> void:
	Global.enemyUnit += 1;
	add_to_group("enemy");
	var characters = "abcdefghijklmnopqrstuvwsyz";
	new_id = Global.generateId(characters, 10);
	if is_ranged_unit == true:
		attack_rang = 150;
		unit_speed = 70;

func _process(delta: float) -> void:
	if health <= 0:
		Global.enemyUnit -= 1;
		queue_free();

	$ProgressBar.value = health;

	var all_units = get_tree().get_nodes_in_group("unit");
	for unit in all_units:
		var distance_to_unit = (unit.position - global_position).length();
		if target_id == null and distance_to_unit <= 150:
			target_id = unit.new_id;

	if target_id != null:
		var unit_extist = false;
		for unit in all_units:
			var distance_to_unit = (unit.position - global_position).length();
			if unit.new_id == target_id and distance_to_unit > attack_rang:
				target = unit.position;
				makePath();
				moveTowardTarget();
				speed = unit_speed;
			elif unit.new_id == target_id and distance_to_unit <= attack_rang and able_to_shoot == true:
				able_to_shoot = false;
				$TimerShoot.start();
				var new_laser = laser.instantiate();
				new_laser.is_good_laser = false;
				add_sibling(new_laser);
				new_laser.position = $body.global_position;
				new_laser.look_at(unit.position);
				new_laser.owner_id = new_id;
				speed = 0;
			if unit.new_id == target_id:
				$body.look_at(unit.position);
				unit_extist = true;
		if unit_extist == false:
			target_id = null;
	


func _on_timer_shoot_timeout() -> void:
	able_to_shoot = true;



func _on_area_2d_area_entered(area:Area2D) -> void:
	if area.is_in_group("unit_laser"):
		health -= 1;
		atttacking_unit = true;
		target_id = area.owner_id;
		$body.look_at(area.position);
		area.queue_free();


func _on_button_attack_me_pressed() -> void:
	if Global.workerSelected == true:
		Global.newWorkerTarget = position;
		Global.newWorkerTargetJob = "attack_unit";
		Global.newWorkerTargetId = new_id;
		$TimerRemoveNav.start();

func _on_timer_remove_nav_timeout() -> void:
	Global.newWorkerTarget = null;
	Global.newWorkerTargetJob = null;
	Global.newWorkerTargetId = null;
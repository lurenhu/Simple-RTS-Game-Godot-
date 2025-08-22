extends Area2D

var health = 10;
var dead = false;
@export var clearBlock: PackedScene;

var xValue = 0;
var yValue = 0;

var removeCollision = false;
var create = false;
var new_id;
var i_am_building = true;

@export var laser: PackedScene;
var target_id = null;
var able_to_shoot = true;

func _ready() -> void:
	var new_pos = clearBlock.instantiate();
	add_child(new_pos);
	if position.x < 0:
		new_pos.position.x += (position.x * -1);
	if position.x > 0:
		new_pos.position.x -= position.x;
	if position.y < 0:
		new_pos.position.y += (position.y * -1);
	if position.y > 0:
		new_pos.position.y -= position.y;

	while new_pos.position.x < 0:
		if new_pos.position.x < position.x:
			new_pos.position.x += 40;
			xValue += 1;
	while new_pos.position.x >= 40:
		if new_pos.position.x > position.x:
			new_pos.position.x -= 40;
			xValue -= 1;
	while new_pos.position.y < -40:
		if new_pos.position.y < position.y:
			new_pos.position.y += 40;
			yValue += 1;
	while new_pos.position.y >= 0:
		if new_pos.position.y > position.y:
			new_pos.position.y -= 40;
			yValue -= 1;

	xValue -= 1;
	new_pos.position.y += 40;	

	create = true;

	var characters = "abcdefghijklmnopqrstuvwsyz";
	new_id = Global.generateId(characters, 10);

func _physics_process(delta: float) -> void:
	if create == true:
		Global.addToNoNavSpot.append(Vector2i(xValue,yValue));
		create = false;
	if health <= 0:
		if removeCollision == false:
			Global.addNavSpot.append(Vector2i(xValue,yValue));
			queue_free();
			removeCollision = true;

	$ProgressBar.value = health;
	if Global.workerSelected == true and health > 0:
		$ButtonTC.visible = true;
	if Global.workerSelected == false and health > 0:
		$ButtonTC.visible = false;

	
	var all_units = get_tree().get_nodes_in_group("unit");
	for unit in all_units:
		var distance_to_unit = (unit.position - global_position).length();
		if target_id == null and distance_to_unit <= 150:
			target_id = unit.new_id;
			$Building/turrent.look_at(unit.position);

	if target_id != null:
		var unit_extist = false;
		for unit in all_units:
			var distance_to_unit = (unit.position - global_position).length();
			if unit.new_id == target_id and distance_to_unit <= 150 and able_to_shoot == true:
				$Building/turrent.look_at(unit.position);
				able_to_shoot = false;
				$TimerShoot.start();
				var new_laser = laser.instantiate();
				new_laser.is_good_laser = false;
				add_sibling(new_laser);
				new_laser.position = $Building/turrent.global_position;
				new_laser.look_at(unit.position);
				new_laser.owner_id = new_id;
			if unit.new_id == target_id:
				$Building/turrent.look_at(unit.position);
				unit_extist = true;
		if unit_extist == false:
			target_id = null;

func _on_remove_pressed() -> void:
	health -= 10;


func _on_button_tc_pressed() -> void:
	if Global.workerSelected == true:
		Global.newWorkerTarget = position;
		Global.newWorkerTargetJob = "attack_building";
		Global.newWorkerTargetId = new_id;
		$TimerRemoveNav.start();

func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group("unit_laser"):
		health -= 1;
		area.queue_free();


func _on_timer_remove_nav_timeout() -> void:
	Global.newWorkerTarget = null;
	Global.newWorkerTargetJob = null;
	Global.newWorkerTargetId = null;

func _on_timer_shoot_timeout() -> void:
	able_to_shoot = true;

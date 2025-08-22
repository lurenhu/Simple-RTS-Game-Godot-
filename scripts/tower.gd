extends Area2D

var health = 10;
var dead = false;

var xValue = 0;
var yValue = 0;

var removeCollision = false;
var create = false;

var built_num = 0;
var freeze_pos = false;
var toggle_y_value = false;
var can_place = false;
var built_spot = 0;
var fully_built = false;
var fully_built_value = 0;
var new_id = null;

@export var laser: PackedScene;
var target_id = null;
var able_to_shoot = true;

func _ready() -> void:
	add_to_group("building");
	var characters = "abcdefghijklmnopqrstuvwsyz";
	new_id = Global.generateId(characters, 10);

func _physics_process(delta: float) -> void:
	if create == true:
		$Building.modulate = Color(1.0, 1.0, 1.0);
		create = false;

	if health <= 0:
		if removeCollision == false:
			Global.addNavSpot.append(Vector2(xValue - 1, yValue - 1));
			remove_from_group("building");
			queue_free();
			removeCollision = true;

	$ProgressBar.value = health;

	if Global.workerSelected == true or  Global.buildingSelected == true:
		$CanvasLayer.visible = false;
		$ButtonTC.visible = false;
		if freeze_pos == true and fully_built == false:
			$ButtonBuildMe.visible = true;

	if Global.workerSelected == false:
		$ButtonTC.visible = true;
		if freeze_pos == true and fully_built == false:
			$ButtonBuildMe.visible = false;

	var mousePosition = get_global_mouse_position();
	if freeze_pos == false:
		if mousePosition.x > self.position.x + 60:
			position.x += 80;
			xValue += 2;
		if mousePosition.x < self.position.x - 60:
			position.x -= 80;
			xValue -= 2;
		if mousePosition.y > self.position.y + 60:
			position.y += 80;
			yValue += 2;
		if mousePosition.y < self.position.y - 60:
			position.y -= 80;
			yValue -= 2;

		if yValue % 4 != 0 and toggle_y_value == true:
			position.x -= 40;
			toggle_y_value = false;
			xValue -= 1;
		if yValue % 4 == 0 and toggle_y_value == false:
			position.x += 40;
			toggle_y_value = true;
			xValue += 1;

	if freeze_pos == false:
		if $"../TileMapLayer".get_cell_source_id(Vector2(xValue, yValue)) == 0:
			can_place = true;
			$Building.modulate = Color(0.0, 1.0, 0.0);
		else:
			can_place = false;
			$Building.modulate = Color(1.0, 0.0, 0.0);

	if freeze_pos == true and fully_built == false:
		$Building.modulate = Color(0.0, 1.0, 0.0);

	if built_num >= 1:
		if built_spot == 0:
			add_to_group("unit");
			Global.addToNoNavSpot.append(Vector2i(xValue - 1, yValue - 1));
			$ProgressBar.visible = true;
			$StaticBody2D/CollisionShape2D.disabled = false;
			built_spot += 1;
	if built_num >= 5:
		fully_built = true;
		if fully_built_value == 0:
			remove_from_group("unbuilt_building");
			add_to_group("built_building");
			$ButtonBuildMe.queue_free();
			$Building/Sprite2D/turret.visible = true;
			create = true;
			fully_built_value += 1;

	var all_units = get_tree().get_nodes_in_group("enemy");
	for unit in all_units:
		var distance_to_unit = (unit.position - global_position).length();
		if target_id == null and distance_to_unit <= 150 and fully_built == true:
			target_id = unit.new_id;
			$Building/Sprite2D/turret.look_at(unit.position);

	if target_id != null:
		var unit_extist = false;
		for unit in all_units:
			var distance_to_unit = (unit.position - global_position).length();
			if unit.new_id == target_id and distance_to_unit <= 150 and able_to_shoot == true:
				$Building/Sprite2D/turret.look_at(unit.position);
				able_to_shoot = false;
				$TimerShoot.start();
				var new_laser = laser.instantiate();
				new_laser.is_good_laser = true;
				add_sibling(new_laser);
				new_laser.position = $Building/Sprite2D/turret.global_position;
				new_laser.look_at(unit.position);
				new_laser.owner_id = new_id;
			if unit.new_id == target_id:
				$Building/Sprite2D/turret.look_at(unit.position);
				unit_extist = true;
		if unit_extist == false:
			target_id = null;


func _on_remove_pressed() -> void:
	health -= 10;

func _on_button_tc_pressed() -> void:
	Global.buildingSelected = true;
	$TimerUIon.start();

func _on_button_place_pressed() -> void:
	if can_place == true:
		if freeze_pos == false:
			add_to_group("unbuilt_building");
			$ButtonPlace.visible = false;
			freeze_pos = true;



func _on_button_build_me_pressed() -> void:
	Global.newWorkerTarget = position;
	Global.newWorkerTargetType = "tile";
	Global.newWorkerTargetJob = "build";
	Global.newWorkerTargetId = new_id;
	$TimerRemoveNav.start();


func _on_timer_remove_nav_timeout() -> void:
	Global.newWorkerTarget = null;
	Global.newWorkerTargetType = null;
	Global.newWorkerTargetJob = null;
	Global.newWorkerTargetId = null;


func _on_timer_u_ion_timeout() -> void:
	Global.buildingSelected = false;
	$CanvasLayer.visible = true;

func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group("worker_tools") and freeze_pos == true:
		if area.get_parent().jobBuilding == true and built_num <= 4:
			area.get_parent().resetStandStillTime();
			built_num += 1;
		if area.get_parent().jobBuilding == true and built_num >= 5:
			remove_from_group("unbuilt_building");
			area.get_parent().resetStandStillTime();
			area.get_parent().usingWorkerTools = false;
			area.get_parent().findClosestTargetForJob();
	if area.is_in_group("enemy_laser") and freeze_pos == true and built_num >= 1:
		health -= 1;
		area.queue_free();


func _on_timer_shoot_timeout() -> void:
	able_to_shoot = true;
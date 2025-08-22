extends Area2D

var health = 10;
var dead = false;

var xValue = 0;
var yValue = 0;

var removeCollision = false;
var create = false;

var unitInQue = 0;

@export var new_worker: PackedScene;
@export var new_barectks_unit: PackedScene;
@export var new_range_unit: PackedScene;
@export var is_tc = false;
@export var is_barectks = false;
@export var is_range = false;

var built_num = 0;
var freeze_pos = false;
var toggle_y_value = false;
var can_place = false;
var built_spot = 0;
var fully_built = false;
var fully_built_value = 0;
var new_id = null;

func _ready() -> void:
	add_to_group("building");
	var characters = "abcdefghijklmnopqrstuvwsyz";
	new_id = Global.generateId(characters, 10);

func _physics_process(delta: float) -> void:
	if create == true:
		$Building.modulate = Color(1.0, 1.0, 1.0);
		if is_tc == true:
			Global.maxPopulationCount += 10;
		create = false;

	if health <= 0:
		if removeCollision == false:
			Global.addNavSpot.append(Vector2(xValue - 1, yValue - 1));
			remove_from_group("building");
			if is_tc == true:
				Global.maxPopulationCount -= 10;
				remove_from_group("town_center");
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
		if fully_built == false:
			$CanvasLayer/AddWorkerButton.visible = false;
		else:
			$CanvasLayer/AddWorkerButton.visible = true;

	if unitInQue > 0 and $TimerWorker.is_stopped() and Global.populationCount < Global.maxPopulationCount:
		$TimerWorker.start();

	match unitInQue:
		0:
			$CanvasLayer/q1.visible = false;
			$CanvasLayer/q2.visible = false;
			$CanvasLayer/q3.visible = false;
			$CanvasLayer/q4.visible = false;
		1:
			$CanvasLayer/q1.visible = true;
			$CanvasLayer/q2.visible = false;
			$CanvasLayer/q3.visible = false;
			$CanvasLayer/q4.visible = false;
		2:
			$CanvasLayer/q1.visible = true;
			$CanvasLayer/q2.visible = true;
			$CanvasLayer/q3.visible = false;
			$CanvasLayer/q4.visible = false;
		3:
			$CanvasLayer/q1.visible = true;
			$CanvasLayer/q2.visible = true;
			$CanvasLayer/q3.visible = true;
			$CanvasLayer/q4.visible = false;
		4:
			$CanvasLayer/q1.visible = true;
			$CanvasLayer/q2.visible = true;
			$CanvasLayer/q3.visible = true;
			$CanvasLayer/q4.visible = true;

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
			if is_tc == true:
				add_to_group("town_center");
			$ButtonBuildMe.queue_free();
			create = true;
			fully_built_value += 1;

func _on_remove_pressed() -> void:
	health -= 10;

func _on_add_worker_pressed() -> void:
	if unitInQue < 4 and Global.populationCount < Global.maxPopulationCount and Global.foodCount >= 50:
		$TimerWorker.start();
		unitInQue += 1;
		Global.foodCount -= 50;

func _on_button_tc_pressed() -> void:
	Global.buildingSelected = true;
	$TimerUIon.start();

func _on_timer_worker_timeout() -> void:
	var new_unit;
	if is_tc == true:
		new_unit = new_worker.instantiate();
	if is_barectks == true:
		new_unit = new_barectks_unit.instantiate();
	if is_range == true:
		new_unit = new_range_unit.instantiate();
	add_sibling(new_unit);
	new_unit.position = position + Vector2(0, 60);
	unitInQue -= 1;
	if unitInQue > 0 and Global.populationCount < Global.maxPopulationCount:
		$TimerWorker.start();

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

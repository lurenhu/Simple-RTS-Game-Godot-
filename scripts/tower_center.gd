extends Area2D

var health = 10;
var dead = false;
@export var clearBlock: PackedScene;

var xValue = 0;
var yValue = 0;

var removeCollision = false;
var create = false;
var new_id;

var workersInQue = 0;
@export var newWorker: PackedScene;

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

	add_to_group("building");
	add_to_group("town_center");
	
	var characters = "abcdefghijklmnopqrstuvwsyz";
	new_id = Global.generateId(characters, 10);
	add_to_group("unit");

func _physics_process(delta: float) -> void:
	if create == true:
		Global.addToNoNavSpot.append(Vector2i(xValue,yValue));
		Global.maxPopulationCount += 10;
		create = false;
	if health <= 0:
		if removeCollision == false:
			Global.addNavSpot.append(Vector2i(xValue,yValue));
			remove_from_group("building");
			remove_from_group("town_center");
			Global.maxPopulationCount -= 10;
			queue_free();
			removeCollision = true;

	$ProgressBar.value = health;
	if Global.workerSelected == true and health > 0 or Global.buildingSelected == true:
		$ButtonTC.visible = false;
		$CanvasLayer.visible = false;
	if Global.workerSelected == false and health > 0:
		$ButtonTC.visible = true;

	if workersInQue > 0 and $TimerWorker.is_stopped() and Global.populationCount < Global.maxPopulationCount:
		$TimerWorker.start();

	match workersInQue:
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
			


func _on_remove_pressed() -> void:
	health -= 10;


func _on_add_worker_pressed() -> void:
	if workersInQue < 4 and Global.populationCount < Global.maxPopulationCount and Global.foodCount >= 50:
		$TimerWorker.start();
		workersInQue += 1;
		Global.foodCount -= 50;


func _on_button_tc_pressed() -> void:
	Global.buildingSelected = true;
	$TimerUIon.start();


func _on_timer_worker_timeout() -> void:
	var newWorkerCreated = newWorker.instantiate();
	add_sibling(newWorkerCreated);
	newWorkerCreated.position = position + Vector2(0,60);
	workersInQue -= 1;
	if workersInQue > 0 and Global.populationCount < Global.maxPopulationCount:
		$TimerWorker.start();


func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group("enemy_laser"):
		health -= 1;
		area.queue_free();


func _on_timer_u_ion_timeout() -> void:
	Global.buildingSelected = false;
	$CanvasLayer.visible = true;

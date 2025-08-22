extends Area2D

@export var resourceCount = 10;
var dead = false;
@export var clearBlock: PackedScene;

var xValue = 0;
var yValue = 0;

var removeCollision = false;
var create = false;
var new_id;

@export var tree = false;
@export var gold = false;

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

	if tree == true:
		add_to_group("tree");
	if gold == true:
		add_to_group("gold");
		

func _physics_process(delta: float) -> void:
	if create == true:
		Global.addToNoNavSpot.append(Vector2i(xValue, yValue));
		create = false;
	if resourceCount <= 0:
		if removeCollision == false:
			Global.addNavSpot.append(Vector2i(xValue, yValue));
			queue_free();
			removeCollision = true;

	if Global.workerSelected == true:
		$ButtonSelect.visible = true;
	if Global.workerSelected == false:
		$ButtonSelect.visible = false;

	if resourceCount <= 0:
		queue_free();

func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group("worker_tools") and area.get_parent().jobCuttingWood == true and  tree == true:
		area.get_parent().resetStandStillTime();
		resourceCount -= 1;
		area.get_parent().woodGather += 1;
	if area.is_in_group("worker_tools") and area.get_parent().jobMiningGold == true and  gold == true:
		area.get_parent().resetStandStillTime();
		resourceCount -= 1;
		area.get_parent().goldGather += 1;

func _on_button_select_pressed() -> void:
	Global.newWorkerTarget = position;
	Global.newWorkerTargetType = "tile";
	if tree == true:
		Global.newWorkerTargetJob = "chop_wood";
	if gold == true:
		Global.newWorkerTargetJob = "mine_gold";
	Global.newWorkerTargetId = new_id;
	$TimerRemoveNav.start();

func _on_timer_remove_nav_timeout() -> void:
	Global.newWorkerTarget = null;
	Global.newWorkerTargetId = null;
	Global.newWorkerTargetJob = null;
	Global.newWorkerTargetType = null;
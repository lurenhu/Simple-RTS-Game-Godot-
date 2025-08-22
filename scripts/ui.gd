extends CanvasLayer

var game_in_on = false;

func _process(delta: float) -> void:
	$"ResourceText/LabelWood".text = "木头:" + str(Global.woodCount);
	$"ResourceText/LabelFood".text = "食物:" + str(Global.foodCount);
	$"ResourceText/LabelGold".text = "金块:" + str(Global.goldCount);
	$"ResourceText/LabelPopulation".text = "人口:" + str(Global.populationCount) + "/" + str(Global.maxPopulationCount);

	$"WorkerBuildOption".visible = Global.workerSelected;

	if Global.enemyUnit == 0 and game_in_on == true:
		$WinScreen.visible = true;
	if Global.goodUnit == 0 and game_in_on == true:
		$LooseScreen.visible = true;

func _on_timer_game_on_timeout() -> void:
	game_in_on = true;

func _on_button_pressed() -> void:
	Global.initInfo();
	get_tree().reload_current_scene();
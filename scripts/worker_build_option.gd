extends Node2D

@export var towerCenter: PackedScene;
@export var tower: PackedScene;
@export var bareckts: PackedScene;
@export var range_b: PackedScene;
@export var house: PackedScene;
@export var farm: PackedScene;

func onTowerCenterPressed():
	if Global.woodCount >= 50 and Global.goldCount >= 50:
		var newBuilding = towerCenter.instantiate();
		$'../../GameObject'.add_child(newBuilding);
		Global.woodCount -= 50;
		Global.goldCount -= 50;

func onTowerPressed():
	if Global.woodCount >= 50:
		var newBuilding = tower.instantiate();
		$'../../GameObject'.add_child(newBuilding);
		Global.woodCount -= 50;

func onBarecktsPressed():
	if Global.woodCount >= 50:
		var newBuilding = bareckts.instantiate();
		$'../../GameObject'.add_child(newBuilding);
		Global.woodCount -= 50;

func onRangePressed():
	if Global.woodCount >= 50:
		var newBuilding = range_b.instantiate();
		$'../../GameObject'.add_child(newBuilding);
		Global.woodCount -= 50;

func onHousePressed():
	if Global.woodCount >= 50:
		var newBuilding = house.instantiate();
		$'../../GameObject'.add_child(newBuilding);
		Global.woodCount -= 50;

func onFarmPressed():
	if Global.woodCount >= 50:
		var newBuilding = farm.instantiate();
		$'../../GameObject'.add_child(newBuilding);
		Global.woodCount -= 50;

extends Node

var addNavSpot = PackedVector2Array();
var addToNoNavSpot = PackedVector2Array();
var workerSelected = false;
var buildingSelected = false;

var foodCount = 1200;
var woodCount = 1200;
var goldCount = 1200;
var populationCount = 0;
var maxPopulationCount = 0;

var newWorkerTarget = null;
var newWorkerTargetType = null;
var newWorkerTargetJob = null;
var newWorkerTargetId = null;

var enemyUnit = 0;
var goodUnit = 0;

##----------------业务逻辑-------------------

func _ready() -> void:
    pass;

## 初始化数据
func initInfo():
    addNavSpot = PackedVector2Array();
    addToNoNavSpot = PackedVector2Array();
    workerSelected = false;
    buildingSelected = false;
    foodCount = 1200;
    woodCount = 1200;
    goldCount = 1200;
    populationCount = 0;
    maxPopulationCount = 0;
    newWorkerTarget = null;
    newWorkerTargetType = null;
    newWorkerTargetJob = null;
    newWorkerTargetId = null;
    enemyUnit = 0;
    goodUnit = 0;

func generateId(chars, length):
    var word: String;
    var n_char = len(chars);
    for i in range(length):
        word += chars[randi()%n_char];
    return word;
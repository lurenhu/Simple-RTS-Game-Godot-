extends Node

var addNavSpot = PackedVector2Array();## 添加导航点(二维向量数组)
var addToNoNavSpot = PackedVector2Array();## 添加非导航点(二维向量数组)
var workerSelected = false;## 是否选中小兵
var buildingSelected = false;## 是否选中建筑

var foodCount = 1200;## 食物
var woodCount = 1200;## 木头
var goldCount = 1200;## 金块
var populationCount = 0;## 当前人口
var maxPopulationCount = 0;## 最大人口数量

var newWorkerTarget = null;## 工人目标坐标
var newWorkerTargetType = null;## 工人目标类型
var newWorkerTargetJob = null;## 工人目标职业
var newWorkerTargetId = null;## 工人目标ID

var enemyUnit = 0;## 敌人数量
var goodUnit = 0;## 友方数量

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

## 生成随机ID
func generateId(chars, length):
    var word: String;
    var n_char = len(chars);
    for i in range(length):
        word += chars[randi()%n_char];
    return word;

## 职业类型 
## 用于判断当前所选中的工人是用来干什么的
const JOB = {
    "building" = "building",
    "chop_wood" = "chop_wood",
    "mine_gold" = "mine_gold",
    "farm" = "farm",
    "attack_unit" = "attack_unit",
    "attack_building" = "attack_building",
}

## 组 用于给游戏对象进行分组
const GROUP = {
    "enemy" = "enemy",
}
# RTS Game

## 策划案

1. 游戏流程——(GamePlay)
   1. 玩家通过制造小兵将地图中所有的其他敌人建筑与小兵击杀则游戏胜利
   2. 玩家所有小兵及建筑被敌人击杀则游戏失败
2. 玩家
   1. 兵种：分为三个兵种
      1. 普通工兵：可以进行建造建筑扩大势力范围及采集地图资源
      2. 快速战斗兵：移速快
      3. 远程战斗兵：射程远
   2. 建筑：工兵可以建造的建筑
      1. 建筑中心：生产普通工兵
      2. 快速战斗军营：生产快速战斗兵
      3. 远程战斗军营：生产远程战斗兵
      4. 军营：增加人口数量
      5. 农田：可以被收获增加食物量
      6. 炮台：当敌人对象进入指定范围就会发射激光
3. 敌人
   1. 所有地方势力在进入游戏时就以固定
   2. 兵种
      1. 快速战斗兵：移速快
      2. 远程战斗兵：射程远
   3. 建筑
      1. 建筑中心
      2. 军营
      3. 炮台：当敌人对象进入指定范围就会发射激光
4. 环境
   1. 森林：可以被工兵采集获得木材
   2. 金矿：可以被工兵采集获得金矿

## 解决方案

### 需求描述

- 玩家可以通过在游戏界面进行框选操作来框选游戏对象

### 实现思路

- **PhysicsShapeQueryParameters2D** 类进行2D游戏场景的查询操作，记作q
    `````` py
    q.shape = selectRect;# 检查区域的形状
    q.collision_mask = 2;# 检查区域的碰撞层级
    q.transform = Transform2D(0, (dragEnd + dragStart) / 2);# 检查区域的位置
    ``````
- **get_world_2d().direct_space_state.intersect_shape(q)** 执行查询操作返回2D世界中查询结果

### 需求方案

- 实现对选中游戏对象进行寻路与自动避障

### 实现思路

- **NavigationAgent2D** 类进行导航代理，实现自动避障
- 定义一个target变量表示移动的目标位置，当目标存在时就计算路径，目标不存在就原地不动
    `````` py
    func moveTowardTarget():
        var _t = self;

        ## 计算得出寻路路径
        _t.velocity = Vector2.ZERO;
        if target != null:
            var dir = to_local(navAgent.get_next_path_position()).normalized();
            av = avoid();
            _t.velocity = (dir + av * avoidWeight).normalized() * speed;
            if position.distance_to(target) <= targetRadius:
                target = null;
        
        ## 启用引擎自带的寻路代理避障功能
        if navAgent.avoidance_enabled == true:
            navAgent.velocity = _t.velocity;
        else :
            _t._on_navigation_agent_2d_velocity_computed(_t.velocity);
        
        move_and_slide();

    ## 避障
    func avoid():
        var result = Vector2.ZERO;
        var neighbors = $Area2D.get_overlapping_bodies();
        if neighbors:
            for n in neighbors:
                result += n.position.direction_to(position);
            result /= neighbors.size();
        return result.normalized();
    ``````

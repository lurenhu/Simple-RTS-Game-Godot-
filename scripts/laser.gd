extends Area2D

var is_good_laser = false;
var owner_id;

func _ready() -> void:
	if is_good_laser == true:
		add_to_group("unit_laser");
		$ColorRect.modulate = Color.BLUE;
	if is_good_laser == false:
		add_to_group("enemy_laser");
		$ColorRect.modulate = Color.RED;

func _process(delta: float) -> void:
	move_local_x(100 * delta);

	
func _on_timer_timeout() -> void:
	queue_free();
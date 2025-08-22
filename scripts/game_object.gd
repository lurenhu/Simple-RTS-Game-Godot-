extends Node2D

var dragging = false;
var dragStart = Vector2.ZERO;
var selectRect = RectangleShape2D.new();
var selecteds = [];

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if selecteds.size() == 0:
				dragging = true;
				dragStart = get_global_mouse_position();
			else:
				for item in selecteds:
					if str(item.collider) != "<Freed Object>":
						item.collider.target = get_global_mouse_position();
						item.collider.turnOffAllJobs();
						item.collider.selected = false;
				selecteds = [];
		elif dragging == true:
			dragging = false;
			queue_redraw();
			var dragEnd = get_global_mouse_position();
			selectRect.extents = abs(dragEnd - dragStart) / 2;
			var space = get_world_2d().direct_space_state;
			var q = PhysicsShapeQueryParameters2D.new();
			q.shape = selectRect;
			q.collision_mask = 2;
			q.transform = Transform2D(0, (dragEnd + dragStart) / 2);
			selecteds = space.intersect_shape(q);
			for item in selecteds:
				item.collider.selected = true;
	if event is InputEventMouseMotion and dragging:
		queue_redraw();

func _draw() -> void:
	if dragging == true:
		draw_rect(Rect2(dragStart, get_global_mouse_position() - dragStart), Color.WHITE, false, 4.0)

func _process(delta: float) -> void:
	if Global.workerSelected == false:
		selecteds = [];

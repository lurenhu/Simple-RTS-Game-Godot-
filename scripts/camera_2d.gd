extends Camera2D

var canMoveLeft = false;
var canMoveRight = false;
var canMoveUp = false;
var canMoveDown = false;

func _process(delta):
    var mousePosition = get_viewport().get_mouse_position();
    var viewPortRect = get_viewport_rect();

    if mousePosition.x > viewPortRect.size.x:
        canMoveRight = true;
        canMoveLeft = false;
    elif mousePosition.x < 0:
        canMoveRight = false;
        canMoveLeft = true;
    else:
        canMoveRight = false;
        canMoveLeft = false;

    if mousePosition.y > viewPortRect.size.y:
        canMoveUp = false;
        canMoveDown = true;
    elif mousePosition.y < 0:
        canMoveUp = true;
        canMoveDown = false;
    else:
        canMoveUp = false;
        canMoveDown = false;
    
    if canMoveRight and position.x <= 4080:
        position += Vector2.RIGHT * 6;
        $"../UI/MiniMap/Screen".position += Vector2.RIGHT * .2;
    if canMoveLeft and position.x >= 0:
        position += Vector2.LEFT * 6;
        $"../UI/MiniMap/Screen".position += Vector2.LEFT * .2;
    if canMoveDown and position.y <= 2040:
        position += Vector2.DOWN * 6;
        $"../UI/MiniMap/Screen".position += Vector2.DOWN * .2;
    if canMoveUp and position.y >= 0:
        position += Vector2.UP * 6;
        $"../UI/MiniMap/Screen".position += Vector2.UP * .2;

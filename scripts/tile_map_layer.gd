extends TileMapLayer

func _process(delta: float) -> void:
    if Global.addNavSpot != null:
        for spot in Global.addNavSpot:
            erase_cell(Vector2(spot.x, spot.y));
            erase_cell(Vector2(spot.x + 1, spot.y));
            erase_cell(Vector2(spot.x, spot.y + 1));
            erase_cell(Vector2(spot.x + 1, spot.y + 1));

            set_cell(Vector2(spot.x, spot.y), 0, Vector2i(0, 0));
            set_cell(Vector2(spot.x + 1, spot.y), 0, Vector2i(0, 0));
            set_cell(Vector2(spot.x, spot.y + 1), 0, Vector2i(0, 0));
            set_cell(Vector2(spot.x + 1, spot.y + 1), 0, Vector2i(0, 0));
        Global.addNavSpot.clear();

    if Global.addToNoNavSpot != null:
        for spot in Global.addToNoNavSpot:
            erase_cell(Vector2(spot.x, spot.y));
            erase_cell(Vector2(spot.x + 1, spot.y));
            erase_cell(Vector2(spot.x, spot.y + 1));
            erase_cell(Vector2(spot.x + 1, spot.y + 1));

            set_cell(Vector2(spot.x, spot.y), 1, Vector2i(0, 0));
            set_cell(Vector2(spot.x + 1, spot.y), 1, Vector2i(0, 0));
            set_cell(Vector2(spot.x, spot.y + 1), 1, Vector2i(0, 0));
            set_cell(Vector2(spot.x + 1, spot.y + 1), 1, Vector2i(0, 0));
        Global.addToNoNavSpot.clear();

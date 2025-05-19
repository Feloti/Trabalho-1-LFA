extends Node2D

var tile_size: Vector2 = Vector2i(16, 16)

func _ready():
	queue_redraw()

func _draw():
	var color = Color(0, 0, 0, 0.5)
	for x in range(Global.grid_size.x):
		for y in range(Global.grid_size.y):
			if Global.grid[y][x] != -1:
				var cell_pos = Vector2(x, y) * tile_size
				draw_rect(Rect2(cell_pos, tile_size), color, false)

func update_grid_borders():
	queue_redraw()

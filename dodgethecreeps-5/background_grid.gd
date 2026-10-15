extends Node2D

const CELL: float = 40.0

func _draw() -> void:
	var c := Color(0.6, 0.8, 1.0, 0.05)
	var x: float = 0.0
	while x <= 480.0:
		draw_line(Vector2(x, -CELL), Vector2(x, 760.0), c, 2.0)
		x += CELL
	var y: float = -CELL
	while y <= 760.0:
		draw_line(Vector2(0, y), Vector2(480, y), c, 2.0)
		y += CELL

func _process(delta: float) -> void:
	# Raster scrollt langsam nach unten
	position.y = fmod(position.y + 18.0 * delta, CELL)

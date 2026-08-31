extends Node2D
## Dibuja la cuadrícula de juego con patrón de tablero de ajedrez.

@export var cell_size: int = 90
@export var columns: int = 5
@export var rows: int = 5
@export var line_color: Color = Color(0.35, 0.45, 0.35)
@export var fill_color_a: Color = Color(0.17, 0.20, 0.17)
@export var fill_color_b: Color = Color(0.21, 0.25, 0.21)
@export var border_width: float = 2.0

func _draw() -> void:
	# Dibujar celdas con patrón alternado
	for x in range(columns):
		for y in range(rows):
			var rect := Rect2(x * cell_size, y * cell_size, cell_size, cell_size)
			var color := fill_color_a if (x + y) % 2 == 0 else fill_color_b
			draw_rect(rect, color, true)
			draw_rect(rect, line_color, false, 1.0)

	# Borde exterior más grueso
	var outer := Rect2(0, 0, columns * cell_size, rows * cell_size)
	draw_rect(outer, line_color, false, border_width + 1.0)


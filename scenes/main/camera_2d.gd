extends Camera2D

# Límites del nivel (ajustalos al tamaño real de tu escenario extendido)
@export var limit_left_px: int = 0
@export var limit_right_px: int = 3000
@export var limit_top_px: int = 0
@export var limit_bottom_px: int = 720

func _ready() -> void:
	limit_left = limit_left_px
	limit_right = limit_right_px
	limit_top = limit_top_px
	limit_bottom = limit_bottom_px
	make_current()

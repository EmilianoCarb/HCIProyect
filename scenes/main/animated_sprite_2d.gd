extends AnimatedSprite2D

func _ready() -> void:
	play("default")
	print("--- DEBUG PLANETA ---")
	print("is_playing: ", is_playing())
	print("animation: ", animation)
	print("frame inicial: ", frame)
	print("total frames: ", sprite_frames.get_frame_count("default"))

func _process(_delta: float) -> void:
	print("frame actual: ", frame)

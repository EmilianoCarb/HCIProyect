extends AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finished.connect(_eliminar)
	 
func _eliminar():
	queue_free()

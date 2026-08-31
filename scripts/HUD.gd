extends Control
## HUD que muestra la posición del jugador y el número de pasos.

@onready var label_pos: Label = $LabelPos
@onready var label_steps: Label = $LabelSteps

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("HUD: No se encontró un nodo en el grupo 'player'.")
		return

	player.moved.connect(_on_player_moved)
	_update_display(player.grid_position, 0)

func _on_player_moved(grid_pos: Vector2i, steps: int) -> void:
	_update_display(grid_pos, steps)

func _update_display(grid_pos: Vector2i, steps: int) -> void:
	label_pos.text = "Posición: (%d, %d)" % [grid_pos.x, grid_pos.y]
	label_steps.text = "Pasos: %d" % steps


extends Control
## Cruceta (D-Pad) de botones direccionales.
## Conecta las señales pressed de cada botón al Player.

@onready var btn_up: Button = $BtnUp
@onready var btn_down: Button = $BtnDown
@onready var btn_left: Button = $BtnLeft
@onready var btn_right: Button = $BtnRight

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("DPad: No se encontró un nodo en el grupo 'player'.")
		return

	btn_up.pressed.connect(player.move_up)
	btn_down.pressed.connect(player.move_down)
	btn_left.pressed.connect(player.move_left)
	btn_right.pressed.connect(player.move_right)


extends CanvasLayer

@onready var player: CharacterBody2D = $"../Player"
@onready var toggle_trackpad_btn: Button = $Control/ToggleTrackpad
@onready var btn_left: Button = $Control/BtnLeft
@onready var btn_right: Button = $Control/BtnRight
@onready var btn_jump: Button = $Control/BtnJump
@onready var btn_sprint: Button = $Control/BtnSprint
@onready var btn_attack: Button = $Control/BtnAttack


func _ready() -> void:
	_update_trackpad_btn()
	btn_left.button_down.connect(func(): Input.action_press("ui_left"))
	btn_left.button_up.connect(func(): Input.action_release("ui_left"))

	btn_right.button_down.connect(func(): Input.action_press("ui_right"))
	btn_right.button_up.connect(func(): Input.action_release("ui_right"))

	btn_jump.button_down.connect(func(): Input.action_press("ui_up"))
	btn_jump.button_up.connect(func(): Input.action_release("ui_up"))

	btn_sprint.button_down.connect(func(): Input.action_press("sprint"))
	btn_sprint.button_up.connect(func(): Input.action_release("sprint"))

	btn_attack.button_down.connect(func(): Input.action_press("attack"))
	btn_attack.button_up.connect(func(): Input.action_release("attack"))

	toggle_trackpad_btn.pressed.connect(_on_toggle_trackpad)


func _on_toggle_trackpad() -> void:
	if player:
		player.trackpad_natural_scroll = not player.trackpad_natural_scroll
		_update_trackpad_btn()


func _update_trackpad_btn() -> void:
	if toggle_trackpad_btn and player:
		toggle_trackpad_btn.text = "Trackpad: " + ("Natural (ON)" if player.trackpad_natural_scroll else "Invertido (OFF)")

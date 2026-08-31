extends CharacterBody2D

# --- Configuración de la cuadrícula ---
@export var grid_size: int = 90
@export var grid_width: int = 10
@export var grid_height: int = 10
@export var move_duration: float = 0.15

# --- Sonidos
@export var move_sound: AudioStream
@export var bump_sound: AudioStream



# --- Referencias a nodos hijos ---
@onready var audio_move: AudioStreamPlayer = $AudioMove
@onready var audio_bump: AudioStreamPlayer = $AudioBump

var grid_position: Vector2i = Vector2i(2, 2)
var is_moving: bool = false

func _ready() -> void:
	audio_move.stream = move_sound
	audio_bump.stream = bump_sound
	position = grid_to_pixel(grid_position)

func _unhandled_input(event: InputEvent) -> void:
	if is_moving:
		return

	if event.is_action_pressed("ui_up"):
		try_move(Vector2i(0, -1))
	elif event.is_action_pressed("ui_down"):
		try_move(Vector2i(0, 1))
	elif event.is_action_pressed("ui_left"):
		try_move(Vector2i(-1, 0))
	elif event.is_action_pressed("ui_right"):
		try_move(Vector2i(1, 0))


# --- Funciones públicas para los botones de la UI ---
func move_up() -> void:
	if not is_moving:
		try_move(Vector2i(0, -1))

func move_down() -> void:
	if not is_moving:
		try_move(Vector2i(0, 1))

func move_left() -> void:
	if not is_moving:
		try_move(Vector2i(-1, 0))

func move_right() -> void:
	if not is_moving:
		try_move(Vector2i(1, 0))


# --- Lógica central de movimiento ---
func try_move(direction: Vector2i) -> void:
	var new_pos: Vector2i = grid_position + direction

	if new_pos.x < 0 or new_pos.x >= grid_width or new_pos.y < 0 or new_pos.y >= grid_height:
		_play_bump()
		return

	grid_position = new_pos
	_slide_to(grid_position)


func _slide_to(target_grid_pos: Vector2i) -> void:
	is_moving = true
	_play_move()
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", grid_to_pixel(target_grid_pos), move_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): is_moving = false)


func grid_to_pixel(g: Vector2i) -> Vector2:
	return Vector2(g.x * grid_size, g.y * grid_size)


func _play_move() -> void:
	if audio_move.stream:
		audio_move.play()

func _play_bump() -> void:
	if audio_bump.stream:
		audio_bump.play()

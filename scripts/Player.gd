extends CharacterBody2D
## Personaje que se mueve en una cuadrícula con soporte para teclado y botones UI.

signal moved(grid_pos: Vector2i, steps: int)

# --- Configuración de la cuadrícula ---
@export var grid_size: int = 90
@export var grid_width: int = 5
@export var grid_height: int = 5
@export var move_duration: float = 0.15

# --- Sonidos ---
@export var move_sound: AudioStream
@export var bump_sound: AudioStream

# --- Referencias a nodos hijos ---
@onready var audio_move: AudioStreamPlayer = $AudioMove
@onready var audio_bump: AudioStreamPlayer = $AudioBump
@onready var sprite: Sprite2D = $Sprite2D

var grid_position: Vector2i = Vector2i(2, 2)
var is_moving: bool = false
var step_count: int = 0

func _ready() -> void:
	add_to_group("player")
	audio_move.stream = move_sound
	audio_bump.stream = bump_sound
	position = grid_to_pixel(grid_position)

func _process(_delta: float) -> void:
	if is_moving:
		return

	if Input.is_action_just_pressed("move_up"):
		try_move(Vector2i(0, -1))
	elif Input.is_action_just_pressed("move_down"):
		try_move(Vector2i(0, 1))
	elif Input.is_action_just_pressed("move_left"):
		try_move(Vector2i(-1, 0))
	elif Input.is_action_just_pressed("move_right"):
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
		_shake_sprite()
		return

	grid_position = new_pos
	step_count += 1
	_slide_to(grid_position)
	moved.emit(grid_position, step_count)


func _slide_to(target_grid_pos: Vector2i) -> void:
	is_moving = true
	_play_move()

	var tween: Tween = create_tween()
	tween.tween_property(self, "position", grid_to_pixel(target_grid_pos), move_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): is_moving = false)


func grid_to_pixel(g: Vector2i) -> Vector2:
	# Centra el sprite dentro de la celda
	return Vector2(g.x * grid_size + grid_size / 2.0, g.y * grid_size + grid_size / 2.0)


# --- Efecto de sacudida al chocar con el borde ---
func _shake_sprite() -> void:
	if not sprite:
		return
	var original_pos := sprite.position
	var shake_tween: Tween = create_tween()
	shake_tween.tween_property(sprite, "position", original_pos + Vector2(6, 0), 0.05)
	shake_tween.tween_property(sprite, "position", original_pos + Vector2(-6, 0), 0.05)
	shake_tween.tween_property(sprite, "position", original_pos + Vector2(4, 0), 0.04)
	shake_tween.tween_property(sprite, "position", original_pos + Vector2(-4, 0), 0.04)
	shake_tween.tween_property(sprite, "position", original_pos, 0.03)


func _play_move() -> void:
	if audio_move.stream:
		audio_move.play()

func _play_bump() -> void:
	if audio_bump.stream:
		audio_bump.play()

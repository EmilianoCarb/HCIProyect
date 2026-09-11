extends CharacterBody2D

# --- Movimiento ---
@export var speed: float = 300.0
@export var jump_force: float = -600.0
@export var gravity: float = 1500.0

# --- Sonidos ---
@export var move_sound: AudioStream
@export var bump_sound: AudioStream

# --- Referencias a nodos hijos ---
@onready var audio_move: AudioStreamPlayer = $AudioMove
@onready var audio_bump: AudioStreamPlayer = $AudioBump
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var screen_size: Vector2
var half_height: float = 64.0 # 128px de alto / 2
var half_width: float = 40.0  # ajusta según el "cuerpo" real del sprite (no todo el frame suele estar ocupado)

# --- Input alternativo desde botones UI ---
var ui_left_pressed: bool = false
var ui_right_pressed: bool = false
var ui_jump_requested: bool = false

func _ready() -> void:
	audio_move.stream = move_sound
	audio_bump.stream = bump_sound
	screen_size = get_viewport_rect().size
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	var on_floor: bool = position.y >= screen_size.y - half_height

	# --- Gravedad ---
	if not on_floor:
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# --- Movimiento horizontal (teclado + botones UI) ---
	var direction: float = 0.0
	if Input.is_action_pressed("ui_left") or ui_left_pressed:
		direction -= 1.0
	if Input.is_action_pressed("ui_right") or ui_right_pressed:
		direction += 1.0

	velocity.x = direction * speed

	# --- Salto (teclado + botón UI) ---
	var wants_jump: bool = Input.is_action_just_pressed("ui_up") or ui_jump_requested
	ui_jump_requested = false

	if wants_jump and on_floor:
		velocity.y = jump_force
		_play_move()

	move_and_slide()
	_clamp_to_screen()
	_update_animation(direction, on_floor)


func _clamp_to_screen() -> void:
	var clamped_x: float = clamp(position.x, half_width, screen_size.x - half_width)
	var clamped_y: float = clamp(position.y, half_height, screen_size.y - half_height)

	var hit_edge: bool = clamped_x != position.x or clamped_y != position.y

	position.x = clamped_x
	position.y = clamped_y

	if position.y >= screen_size.y - half_height:
		velocity.y = 0

	if hit_edge:
		_play_bump()

func _update_animation(direction: float, on_floor: bool) -> void:
	if not on_floor:
		if velocity.y < 0:
			sprite.play("jump")
		else:
			if sprite.animation != "fall" and sprite.animation != "fall_loop":
				sprite.play("fall")
			elif sprite.animation == "fall" and sprite.frame == sprite.sprite_frames.get_frame_count("fall") - 1:
				sprite.play("fall_loop")
	elif direction != 0.0:
		sprite.play("walk")
		sprite.flip_h = direction < 0
	else:
		sprite.play("idle")


func _play_move() -> void:
	if audio_move.stream:
		audio_move.play()

func _play_bump() -> void:
	if audio_bump.stream:
		audio_bump.play()


# --- Funciones llamadas por los botones de la UI ---
func press_left() -> void:
	ui_left_pressed = true

func release_left() -> void:
	ui_left_pressed = false

func press_right() -> void:
	ui_right_pressed = true

func release_right() -> void:
	ui_right_pressed = false

func press_jump() -> void:
	ui_jump_requested = true

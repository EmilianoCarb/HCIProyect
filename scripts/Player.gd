extends CharacterBody2D

# --- Movimiento ---
@export var speed: float = 250.0
@export var sprint_speed: float = 450.0
@export var jump_force: float = -600.0
@export var gravity: float = 1500.0

# --- Estamina ---
@export var max_stamina: float = 100.0
@export var sprint_cost_per_sec: float = 30.0
@export var attack_cost: float = 25.0
@export var stamina_regen_per_sec: float = 25.0
@export var regen_delay: float = 0.2

var stamina: float
var time_since_use: float = 0.0
var is_sprinting: bool = false
var is_attacking: bool = false

# --- Sonidos ---
@export var move_sound: AudioStream
@export var bump_sound: AudioStream

# --- Referencias a nodos hijos ---
@onready var audio_move: AudioStreamPlayer = $AudioMove
@onready var audio_bump: AudioStreamPlayer = $AudioBump
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stamina_bar: ProgressBar = $StaminaBar

var screen_size: Vector2
var half_height: float = 64.0
var half_width: float = 40.0
var was_at_edge: bool = false

# ============================================================
# --- Trackpad: swipe de 2 dedos vía wheel events (SIN click) ---
# ============================================================
# En Linux (libinput) y Windows, el swipe de 2 dedos es traducido
# por el compositor a eventos de rueda (MOUSE_BUTTON_WHEEL_*).
# Medimos el tiempo entre ticks (dt): ticks seguidos = sprint; espaciados = walk.
@export var trackpad_natural_scroll: bool = true
var trackpad_h_intensity: float = 0.0   # -1.0 (izq) a 1.0 (der)
var trackpad_h_last_tick_time: float = 0.0

@export var trackpad_fast_swipe_window: float = 0.12
@export var trackpad_min_tick_intensity: float = 0.3
@export var trackpad_decay_per_sec: float = 2.0
@export var trackpad_direction_deadzone: float = 0.1
@export var trackpad_sprint_threshold: float = 0.75

var trackpad_up_ticks: int = 0
var trackpad_down_ticks: int = 0
var trackpad_v_last_tick_time: float = 0.0
@export var trackpad_v_tick_window: float = 0.4
@export var trackpad_jump_tick_threshold: int = 2
@export var trackpad_attack_tick_threshold: int = 2


func _ready() -> void:
	audio_move.stream = move_sound
	audio_bump.stream = bump_sound
	screen_size = get_viewport_rect().size
	stamina = max_stamina
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animation_finished)

	stamina_bar.min_value = 0
	stamina_bar.max_value = max_stamina
	stamina_bar.value = stamina
	stamina_bar.visible = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var idx: int = event.button_index
		var natural_h: float = -1.0 if trackpad_natural_scroll else 1.0

		if idx == MOUSE_BUTTON_WHEEL_RIGHT or idx == MOUSE_BUTTON_WHEEL_LEFT:
			var sign_dir: float = (1.0 if idx == MOUSE_BUTTON_WHEEL_RIGHT else -1.0) * natural_h
			var now: float = Time.get_ticks_msec() / 1000.0
			var dt: float = max(now - trackpad_h_last_tick_time, 0.001)
			trackpad_h_last_tick_time = now

			var t: float = clamp(dt / trackpad_fast_swipe_window, 0.0, 1.0)
			trackpad_h_intensity = sign_dir * lerp(1.0, trackpad_min_tick_intensity, t)

		else:
			var is_wheel_up: bool = (idx == MOUSE_BUTTON_WHEEL_UP and not trackpad_natural_scroll) or (idx == MOUSE_BUTTON_WHEEL_DOWN and trackpad_natural_scroll)
			var is_wheel_down: bool = (idx == MOUSE_BUTTON_WHEEL_DOWN and not trackpad_natural_scroll) or (idx == MOUSE_BUTTON_WHEEL_UP and trackpad_natural_scroll)

			if is_wheel_up:
				var now2: float = Time.get_ticks_msec() / 1000.0
				if now2 - trackpad_v_last_tick_time > trackpad_v_tick_window:
					trackpad_up_ticks = 0
				trackpad_down_ticks = 0
				trackpad_v_last_tick_time = now2
				trackpad_up_ticks += 1
				if trackpad_up_ticks >= trackpad_jump_tick_threshold:
					if position.y >= screen_size.y - half_height:
						velocity.y = jump_force
						_play_move()
					trackpad_up_ticks = 0

			elif is_wheel_down:
				var now3: float = Time.get_ticks_msec() / 1000.0
				if now3 - trackpad_v_last_tick_time > trackpad_v_tick_window:
					trackpad_down_ticks = 0
				trackpad_up_ticks = 0
				trackpad_v_last_tick_time = now3
				trackpad_down_ticks += 1
				if trackpad_down_ticks >= trackpad_attack_tick_threshold:
					try_attack()
					trackpad_down_ticks = 0


func _physics_process(delta: float) -> void:
	var on_floor: bool = position.y >= screen_size.y - half_height

	trackpad_h_intensity = move_toward(trackpad_h_intensity, 0.0, trackpad_decay_per_sec * delta)

	if not on_floor:
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	var direction: float = 0.0
	var using_trackpad: bool = false

	if Input.is_action_pressed("ui_left"):
		direction -= 1.0
	if Input.is_action_pressed("ui_right"):
		direction += 1.0
	if abs(trackpad_h_intensity) >= trackpad_direction_deadzone and direction == 0.0:
		direction = sign(trackpad_h_intensity)
		using_trackpad = true

	var wants_sprint: bool = Input.is_action_pressed("sprint") or abs(trackpad_h_intensity) > trackpad_sprint_threshold
	var sprint_intensity: float = 1.0 if Input.is_action_pressed("sprint") else abs(trackpad_h_intensity)

	is_sprinting = wants_sprint and direction != 0.0 and stamina > 0.0

	var current_speed: float
	if using_trackpad:
		current_speed = lerp(speed, sprint_speed, abs(trackpad_h_intensity))
	else:
		current_speed = sprint_speed if is_sprinting else speed
	velocity.x = direction * current_speed

	if is_sprinting:
		stamina -= sprint_cost_per_sec * sprint_intensity * delta
		time_since_use = 0.0
	else:
		time_since_use += delta
		if time_since_use >= regen_delay:
			stamina += stamina_regen_per_sec * delta

	stamina = clamp(stamina, 0.0, max_stamina)
	stamina_bar.value = stamina
	stamina_bar.visible = stamina < max_stamina

	if Input.is_action_just_pressed("ui_up") and on_floor:
		velocity.y = jump_force
		_play_move()

	if Input.is_action_just_pressed("attack") and not is_attacking:
		try_attack()

	move_and_slide()
	_clamp_to_screen()
	_update_animation(direction, on_floor)


func try_attack() -> bool:
	if stamina >= attack_cost and not is_attacking:
		stamina -= attack_cost
		time_since_use = 0.0
		is_attacking = true
		sprite.play("combo_1")
		return true
	return false


func _on_animation_finished() -> void:
	if sprite.animation == "combo_1":
		sprite.play("combo_1_end")
	elif sprite.animation == "combo_1_end":
		is_attacking = false


func _clamp_to_screen() -> void:
	var clamped_x: float = clamp(position.x, half_width, screen_size.x - half_width)
	var clamped_y: float = clamp(position.y, half_height, screen_size.y - half_height)
	var hit_edge: bool = clamped_x != position.x or clamped_y != position.y

	position.x = clamped_x
	position.y = clamped_y

	if position.y >= screen_size.y - half_height:
		velocity.y = 0

	if hit_edge and not was_at_edge:
		_play_bump()
	was_at_edge = hit_edge


func _update_animation(direction: float, on_floor: bool) -> void:
	if is_attacking:
		return

	if direction != 0.0:
		sprite.flip_h = direction < 0

	if not on_floor:
		if velocity.y < 0:
			sprite.play("jump")
		else:
			if sprite.animation != "fall" and sprite.animation != "fall_loop":
				sprite.play("fall")
			elif sprite.animation == "fall" and sprite.frame == sprite.sprite_frames.get_frame_count("fall") - 1:
				sprite.play("fall_loop")
	elif direction != 0.0:
		sprite.play("run" if is_sprinting else "walk")
	else:
		sprite.play("idle")


func _play_move() -> void:
	if audio_move.stream:
		audio_move.play()


func _play_bump() -> void:
	if audio_bump.stream:
		audio_bump.play()

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

signal stamina_changed(current: float, max: float)

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

# --- Input alternativo desde botones UI ---
var ui_left_pressed: bool = false
var ui_right_pressed: bool = false
var ui_jump_requested: bool = false
var ui_sprint_pressed: bool = false

# ============================================================
# --- Trackpad: swipe de 2 dedos vía wheel events (SIN click) ---
# ============================================================
# En Linux (libinput/CachyOS) y Windows, el swipe de 2 dedos NO llega
# como InputEventPanGesture confiable: el compositor lo traduce a
# eventos de rueda (MOUSE_BUTTON_WHEEL_*). Son ticks discretos, así
# que simulamos intensidad analógica acumulando ticks y dejándolos
# decaer con el tiempo.
#
# "trackpad_natural_scroll" debe coincidir con la config del SO
# ("Invertir la dirección del desplazamiento" en Preferencias del
# Panel táctil). Godot no expone esta preferencia por API, así que
# queda como toggle manual expuesto en el Inspector.
@export var trackpad_natural_scroll: bool = true

var trackpad_h_intensity: float = 0.0   # -1.0 (izq) a 1.0 (der)

# Boost más chico + decay más rápido = zona de "caminar" perceptible
# antes de cruzar a "sprint" (antes: boost 0.35 / decay 2.0 hacían que
# 2 ticks ya dispararan sprint y la intensidad tardara en bajar).
@export var trackpad_tick_boost: float = 0.15
@export var trackpad_decay_per_sec: float = 3.5
@export var trackpad_direction_deadzone: float = 0.15
@export var trackpad_sprint_threshold: float = 0.75

var trackpad_v_ticks: int = 0
var trackpad_v_last_tick_time: float = 0.0
@export var trackpad_jump_tick_window: float = 0.4   # ventana entre ticks para contarlos como "racha"
@export var trackpad_jump_tick_threshold: int = 2    # ticks seguidos hacia arriba = salto


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
	stamina_bar.top_level = true
	stamina_changed.connect(_on_stamina_changed)
	_update_stamina_bar_visibility()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var idx: int = event.button_index

		var is_right: bool
		var is_left: bool
		var is_up: bool
		var is_down: bool

		if not trackpad_natural_scroll:
			is_right = idx == MOUSE_BUTTON_WHEEL_RIGHT
			is_left = idx == MOUSE_BUTTON_WHEEL_LEFT
			is_up = idx == MOUSE_BUTTON_WHEEL_UP
			is_down = idx == MOUSE_BUTTON_WHEEL_DOWN
		else:
			is_right = idx == MOUSE_BUTTON_WHEEL_LEFT
			is_left = idx == MOUSE_BUTTON_WHEEL_RIGHT
			is_up = idx == MOUSE_BUTTON_WHEEL_DOWN
			is_down = idx == MOUSE_BUTTON_WHEEL_UP

		if is_right:
			trackpad_h_intensity = clamp(trackpad_h_intensity + trackpad_tick_boost, -1.0, 1.0)
			print("Trackpad: swipe derecha, intensidad=", trackpad_h_intensity)
		elif is_left:
			trackpad_h_intensity = clamp(trackpad_h_intensity - trackpad_tick_boost, -1.0, 1.0)
			print("Trackpad: swipe izquierda, intensidad=", trackpad_h_intensity)
		elif is_up:
			var now: float = Time.get_ticks_msec() / 1000.0
			if now - trackpad_v_last_tick_time > trackpad_jump_tick_window:
				trackpad_v_ticks = 0
			trackpad_v_last_tick_time = now
			trackpad_v_ticks += 1
			print("Trackpad: tick arriba, acumulado=", trackpad_v_ticks)
			if trackpad_v_ticks >= trackpad_jump_tick_threshold:
				press_jump()
				trackpad_v_ticks = 0
		elif is_down:
			trackpad_v_ticks = 0  # cortar racha si el gesto cambia de dirección


func _physics_process(delta: float) -> void:
	var on_floor: bool = position.y >= screen_size.y - half_height

	# decaimiento de intensidad horizontal (vuelve a 0 si no hay swipe reciente)
	trackpad_h_intensity = move_toward(trackpad_h_intensity, 0.0, trackpad_decay_per_sec * delta)

	if not on_floor:
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	var direction: float = 0.0
	var using_trackpad: bool = false

	if Input.is_action_pressed("ui_left") or ui_left_pressed:
		direction -= 1.0
	if Input.is_action_pressed("ui_right") or ui_right_pressed:
		direction += 1.0
	if abs(trackpad_h_intensity) > trackpad_direction_deadzone and direction == 0.0:
		direction = sign(trackpad_h_intensity)
		using_trackpad = true

	var wants_sprint: bool = Input.is_action_pressed("sprint") or ui_sprint_pressed or abs(trackpad_h_intensity) > trackpad_sprint_threshold
	var sprint_intensity: float = 1.0 if (Input.is_action_pressed("sprint") or ui_sprint_pressed) else abs(trackpad_h_intensity)

	is_sprinting = wants_sprint and direction != 0.0 and stamina > 0.0

	# Velocidad: el trackpad interpola de forma continua entre "speed" y
	# "sprint_speed" según la intensidad del swipe (entrada analógica real).
	# El teclado/botones siguen siendo un salto discreto walk -> run (entrada
	# binaria). Esta diferencia es intencional: es justo el contraste que
	# se compara en la evaluación de HCI.
	var current_speed: float
	if using_trackpad:
		current_speed = lerp(speed, sprint_speed, abs(trackpad_h_intensity))
	else:
		current_speed = sprint_speed if is_sprinting else speed
	velocity.x = direction * current_speed

	# El gasto de estamina solo ocurre una vez cruzado el umbral real de
	# sprint (is_sprinting), no por el solo hecho de moverse con el trackpad.
	if is_sprinting:
		stamina -= sprint_cost_per_sec * sprint_intensity * delta
		time_since_use = 0.0
	else:
		time_since_use += delta
		if time_since_use >= regen_delay:
			stamina += stamina_regen_per_sec * delta

	stamina = clamp(stamina, 0.0, max_stamina)
	stamina_changed.emit(stamina, max_stamina)

	var wants_jump: bool = Input.is_action_just_pressed("ui_up") or ui_jump_requested
	ui_jump_requested = false
	if wants_jump and on_floor:
		velocity.y = jump_force
		_play_move()

	if Input.is_action_just_pressed("attack") and not is_attacking:
		try_attack()

	move_and_slide()
	_clamp_to_screen()
	_update_animation(direction, on_floor)
	_update_stamina_bar_position()


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

	if hit_edge:
		_play_bump()


func _update_animation(direction: float, on_floor: bool) -> void:
	if is_attacking:
		return

	# El flip de sprite se actualiza siempre que haya dirección, esté o no
	# en el aire. Antes esto solo pasaba en la rama de piso, así que si
	# cambiabas de sentido en medio de un salto, el personaje seguía
	# mirando hacia donde había saltado hasta aterrizar.
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


func _on_stamina_changed(current: float, _max_value: float) -> void:
	stamina_bar.value = current
	_update_stamina_bar_visibility()


func _update_stamina_bar_visibility() -> void:
	stamina_bar.visible = stamina < max_stamina


func _update_stamina_bar_position() -> void:
	stamina_bar.global_position = global_position + Vector2(-stamina_bar.size.x / 2, -90)


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
func press_sprint() -> void:
	ui_sprint_pressed = true
func release_sprint() -> void:
	ui_sprint_pressed = false

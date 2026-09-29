extends Button

@export var controlador_partida: ControladorPartida
@export var boton_jugar: Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_cargar)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _cargar():
	controlador_partida.cargar_partida()
	boton_jugar.jugar()

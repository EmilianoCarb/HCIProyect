extends Node2D

@export var area_2d : Area2D
@export var reproductor: AudioStreamPlayer2D

var contenedor_monedas: ContenedorMonedas

func _ready() -> void:
	area_2d.body_entered.connect(_recogida)
	_iniciar_animacion()

func _recogida(_body):
	contenedor_monedas.moneda_recogida()
	reproductor.reparent(get_parent())
	reproductor.play()
	queue_free()

func _iniciar_animacion() -> void:
	var tween: Tween = create_tween()
	tween.set_loops() 
	
	tween.tween_property(self, "position", Vector2(0, -5), 0.5).as_relative().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", Vector2(0, 5), 0.5).as_relative().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

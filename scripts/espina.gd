extends Area2D

var velocidad = 250
var direccion = Vector2.ZERO

func _process(delta):
	position += direccion * velocidad * delta

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(1)
		queue_free() # La espina desaparece al darte

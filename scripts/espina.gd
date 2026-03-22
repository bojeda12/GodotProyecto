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
		
func eliminar_espina():
	# Podrías poner un pequeño efecto de partículas aquí
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("burbujas"):
		area.queue_free() # Borra la burbuja
		queue_free()      # Borra la espina

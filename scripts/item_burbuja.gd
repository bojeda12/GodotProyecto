extends Area2D

func _on_body_entered(body):
	# Verificamos si lo que entró es el jugador
	if body.has_method("recolectar_burbuja"):
		body.recolectar_burbuja()
		# Opcional: Aquí puedes instanciar un sonido o partículas de "pop"
		queue_free() # El objeto desaparece al ser recogido

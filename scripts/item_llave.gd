extends Area2D
@export var es_llave_final: bool = false#esta variable es la que usaremos para identificar el objeto en otra escena


func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("jugador"):
		if body.has_method("recolectar_llave"):
			body.recolectar_llave()
			
			# --- LÓGICA CONDICIONAL ---
			if es_llave_final:
				mostrar_splash_victoria()
			
			desaparecer_con_estilo()

func mostrar_splash_victoria():
	# Cargamos el splash que diseñaste
	var splash_escena = load("res://scenes/splashVictoria.tscn")
	if splash_escena:
		var instancia = splash_escena.instantiate()
		get_tree().current_scene.add_child(instancia)

func desaparecer_con_estilo():
	set_deferred("monitoring", false) 
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	await tween.finished
	queue_free()

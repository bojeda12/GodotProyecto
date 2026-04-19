extends Area2D

@export var es_llave_final: bool = false
var escena_siguiente_nivel: String = "" # Se llenará automáticamente

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		if body.has_method("recolectar_llave"):
			body.recolectar_llave()
			if es_llave_final:
				mostrar_splash_victoria()
			desaparecer_con_estilo()

func mostrar_splash_victoria():
	var splash_escena = load("res://scenes/splashVictoria.tscn")
	if splash_escena:
		var instancia = splash_escena.instantiate()
		# Le pasamos la ruta que el Jefe nos dio al Splash
		if "proxima_escena" in instancia:
			instancia.proxima_escena = escena_siguiente_nivel
		get_tree().current_scene.add_child(instancia)

func desaparecer_con_estilo():
	set_deferred("monitoring", false) 
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	await tween.finished
	queue_free()

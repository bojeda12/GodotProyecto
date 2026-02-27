extends Control

# Ruta de la escena de tu primer nivel
# ruta del archivo donde se cargara la escena
var escena_nivel = "res://scenes//game.tscn" 

func _ready():
	# Hacemos que el texto de "Presiona Espacio" parpadee
	var label_instruccion = $Label2 # Cambia $Label2 por el nombre de tu nodo
	var tween = create_tween().set_loops()
	tween.tween_property(label_instruccion, "modulate:a", 0.2, 1.2)
	tween.tween_property(label_instruccion, "modulate:a", 1.0, 1.2)

func _process(_delta):
	# Detectar si el jugador presiona la tecla Espacio
	if Input.is_action_just_pressed("ui_accept"):
		iniciar_juego()

func iniciar_juego():
	var fade = $FadeRect
	var tween = create_tween()
	
	# Desvanecer a negro en 1 segundo
	tween.tween_property(fade, "modulate:a", 1.0, 1.0)
	
	# ESPERAR un segundo extra en negro antes de seguir
	#tween.tween_interval(0.3) 
	
	# Cambiar de escena
	tween.finished.connect(func():
		get_tree().change_scene_to_file(escena_nivel)
	)

extends Control

# Ruta de la escena del primer nivel
var escena_nivel = "res://scenes/game.tscn" 
var menu_opciones = "res://scenes/menu_opciones.tscn" 

func _ready():
	Config.quitar_musica_menu()
	Config.poner_musica_menu()
	# 1. Conectar botones
	# Asegúrate de que estos nombres coincidan exactamente con tus nodos en Godot
	$VBoxContainer/BotonInicio.pressed.connect(_on_inicio_pressed)
	$VBoxContainer/BotonOpciones.pressed.connect(_on_opciones_pressed) # Agregué esta línea por si ya tienes el botón
	$VBoxContainer/BotonSalir.pressed.connect(_on_salir_pressed)
	
	# 2. Asegurarnos de que el Fade empiece invisible
	$FadeRect.modulate.a = 0.0

# Ya no necesitamos _process porque no estamos detectando teclas

# --- FUNCIONES DE LOS BOTONES ---

func _on_inicio_pressed():
	Config.quitar_musica_menu()
	iniciar_juego()

func _on_opciones_pressed():
	print("Abriendo opciones...")
	get_tree().change_scene_to_file(menu_opciones)
	# Aquí irá tu lógica para abrir el panel de opciones

func _on_salir_pressed():
	get_tree().quit()

# --- LÓGICA DE TRANSICIÓN ---

func iniciar_juego():
	var fade = $FadeRect
	var tween_fade = create_tween()
	
	# Desvanecer a negro
	tween_fade.tween_property(fade, "modulate:a", 1.0, 1.0)
	
	# Cambiar de escena al terminar el desvanecimiento
	tween_fade.finished.connect(func():
		get_tree().change_scene_to_file(escena_nivel)
	) # Este paréntesis cierra el .connect(

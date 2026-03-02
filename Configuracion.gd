extends Node

const SAVE_PATH = "user://config.cfg"
var config = ConfigFile.new()

# Variables de configuración
var pantalla_completa = false
var volumen_musica = 1.0

# Nodo de música global
var reproductor_menu = AudioStreamPlayer.new()

func _ready():
	# 1. Configurar el reproductor
	add_child(reproductor_menu)
	reproductor_menu.stream = load("res://musica/MusicaInicio.mp3") 
	reproductor_menu.bus = "Master"
	reproductor_menu.process_mode = Node.PROCESS_MODE_ALWAYS # Para que no se pare si pausas el juego
	
	cargar_configuracion()
	
	# 2. Iniciar música si estamos en el menú
	reproductor_menu.play()

func cargar_configuracion():
	var error = config.load(SAVE_PATH)
	if error != OK:
		# Si es la primera vez, aplicamos el volumen por defecto (1.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volumen_musica))
		return
	
	pantalla_completa = config.get_value("Opciones", "fullscreen", false)
	volumen_musica = config.get_value("Opciones", "volumen", 1.0)
	
	# Aplicar pantalla completa
	if pantalla_completa:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Aplicar volumen guardado al AudioServer
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volumen_musica))

func guardar_configuracion():
	config.set_value("Opciones", "fullscreen", pantalla_completa)
	config.set_value("Opciones", "volumen", volumen_musica)
	config.save(SAVE_PATH)
	
func poner_musica_menu():
	if not reproductor_menu.playing:
		reproductor_menu.play()

func quitar_musica_menu():
	reproductor_menu.stop()

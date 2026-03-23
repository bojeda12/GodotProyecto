extends Node

const SAVE_PATH = "user://config.cfg"
var config = ConfigFile.new()

# Variables de configuración
var pantalla_completa = false
var volumen_musica = 1.0

# --- REPRODUCTORES ---
@onready var reproductor_menu = AudioStreamPlayer.new()
@onready var reproductor_juego = AudioStreamPlayer.new()

func _ready():
	# 1. Configurar reproductor del Menú
	add_child(reproductor_menu)
	reproductor_menu.stream = load("res://musica/MusicaInicio.mp3")
	reproductor_menu.bus = "Musica" # <--- CAMBIADO
	
	# 2. Configurar reproductor del Juego
	add_child(reproductor_juego)
	reproductor_juego.stream = load("res://musica/fondonivelCalmado.mp3") 
	reproductor_juego.bus = "Musica" # <--- CAMBIADO
	
	cargar_configuracion()
	reproductor_menu.play()

# --- FUNCIONES DE MÚSICA CENTRALIZADAS ---

func poner_musica_menu():
	if reproductor_juego.playing:
		reproductor_juego.stop()
	if not reproductor_menu.playing:
		reproductor_menu.play()

func poner_musica_juego():
	if reproductor_menu.playing:
		reproductor_menu.stop()
	if not reproductor_juego.playing:
		reproductor_juego.play()

func quitar_toda_la_musica():
	reproductor_menu.stop()
	reproductor_juego.stop()

# --- FUNCIÓN PARA DISPAROS Y EFECTOS (SFX) ---
# Úsala así: NombreDeTuAutoload.reproducir_sfx("res://sonidos/disparo.wav")
func reproducir_sfx(ruta_sonido: String):
	var sfx_node = AudioStreamPlayer.new()
	add_child(sfx_node)
	var sonido = load(ruta_sonido)
	if sonido:
		sfx_node.stream = sonido
		sfx_node.bus = "SFX" # <-- INDEPENDIENTE del sonido de fondo
		sfx_node.play()
		sfx_node.finished.connect(sfx_node.queue_free)

# --- CONFIGURACIÓN Y GUARDADO ---

func cargar_configuracion():
	var error = config.load(SAVE_PATH)
	if error != OK:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volumen_musica))
		return
	
	pantalla_completa = config.get_value("Opciones", "fullscreen", false)
	volumen_musica = config.get_value("Opciones", "volumen", 1.0)
	
	if pantalla_completa:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volumen_musica))

func guardar_configuracion():
	config.set_value("Opciones", "fullscreen", pantalla_completa)
	config.set_value("Opciones", "volumen", volumen_musica)
	config.save(SAVE_PATH)
	
	
# --- apagar la musica ---
func quitar_musica_menu():
	reproductor_menu.stop()
	reproductor_juego.stop() # Apaga ambos por si acaso

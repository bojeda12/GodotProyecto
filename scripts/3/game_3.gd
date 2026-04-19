extends Node2D

const SAVE_PATH = "user://config.cfg"
var splash_escena = preload("res://scenes/splashMision.tscn")

# --- VARIABLES PARA LIMPIEZA, PUERTA Y VIDEO ---
var basura_en_escena: int = 0
@onready var puerta = $PuertaFinal 
@onready var video_player = $InterfazVideo/VideoStreamPlayer 

func _ready():
	check_y_mostrar_splash()
	Config.poner_musica_juego()
	
	if video_player:
		video_player.hide()
		# Usamos la señal que ya tenías conectada al final del script
		#video_player.finished.connect(_on_video_stream_player_finished)
	
	basura_en_escena = get_tree().get_nodes_in_group("basura").size()
	print("Nivel iniciado. Basura a limpiar: ", basura_en_escena)

# --- LÓGICA DE LIMPIEZA ---
func actualizar_conteo_basura(valor: int):
	basura_en_escena += valor
	print("Basura restante: ", basura_en_escena)
	
	if basura_en_escena <= 0:
		abrir_puerta_final()

func abrir_puerta_final():
	if puerta:
		if puerta.has_method("activar_puerta"):
			print("¡Arrecife limpio! La puerta se ha desbloqueado.")
			puerta.activar_puerta() 
			# Eliminamos la llamada a esperar_y_reproducir_video de aquí
			# para que el video no sea automático.

# --- NUEVA FUNCIÓN PARA LA COLISIÓN ---
# Conecta la señal 'body_entered' del Area2D de tu puerta a esta función
func _on_puerta_final_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		if basura_en_escena <= 0:
			print("Jugador llegó a la puerta. Iniciando final...")
			iniciar_secuencia_final()
		else:
			print("Aún queda basura por limpiar.")

# --- LÓGICA DEL VIDEO FINAL ---
func iniciar_secuencia_final():
	# Detenemos al jugador para que no se mueva durante el video
	if has_node("HUD"):
		$HUD.hide()
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.set_physics_process(false)
	
	# Si tu puerta tiene un efecto de desvanecido (fade), esperamos a que oscurezca
	await get_tree().create_timer(1.0).timeout
	reproducir_video_final()

func reproducir_video_final():
	Config.quitar_toda_la_musica()
	
	if video_player:
		video_player.show()
		video_player.play()
	else:
		_on_video_stream_player_finished()

# --- FUNCIONES DE INTERFAZ Y REGLAS ---
func _on_video_stream_player_finished() -> void:
	await get_tree().create_timer(2.0).timeout
	var tween = create_tween()
	tween.tween_property(video_player, "modulate:a", 0, 1.0) # Tarda 1 segundo en desaparecer
	await tween.finished
	print("Video terminado. Volviendo al menú.")
	get_tree().change_scene_to_file("res://scenes/menu_inicio.tscn")
	

func check_y_mostrar_splash():
	var config = ConfigFile.new()
	config.load(SAVE_PATH)
	var debe_mostrar = config.get_value("Interfaz", "mostrar_splash", true)
	if debe_mostrar:
		var splash = splash_escena.instantiate()
		add_child(splash)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		if not has_node("splashMision"):
			var splash = splash_escena.instantiate()
			add_child(splash)

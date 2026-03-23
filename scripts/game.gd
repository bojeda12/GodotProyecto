extends Node2D

const SAVE_PATH = "user://config.cfg"
var splash_escena = preload("res://scenes/splashMision.tscn")

func _ready():
	check_y_mostrar_splash()
	Config.poner_musica_juego()

func check_y_mostrar_splash():
	var config = ConfigFile.new()
	config.load(SAVE_PATH)
	
	# Buscamos en "Interfaz". Si no existe, devuelve 'true' (valor por defecto)
	var debe_mostrar = config.get_value("Interfaz", "mostrar_splash", true)
	
	if debe_mostrar:
		var splash = splash_escena.instantiate()
		add_child(splash)

func _input(event):
	# Tecla I para mostrar info manualmente
	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		if not has_node("splashMision"):
			var splash = splash_escena.instantiate()
			add_child(splash)

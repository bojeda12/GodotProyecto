extends Control

var menu_principal = "res://scenes/menu_inicio.tscn" 
# Called when the node enters the scene tree for the first time.
func _ready():
	#$CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/HSlider.value = Config.volumen_musica
	$TextureRect/TextureRect/VBoxContainer/PanelContainer/VBoxContainer/HSlider.value = Config.volumen_musica
	# Al abrir el menú, el botón debe reflejar lo que dice el Autoload
	var ruta_check = "CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/CheckBox"
	if has_node(ruta_check):
		get_node(ruta_check).button_pressed = Config.pantalla_completa
	else:
		print("Error: No encontré el CheckBox en: ", ruta_check)


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file(menu_principal) # ruta del nodo control


func _on_check_box_toggled(toggled_on):
	print("Intentando cambiar pantalla completa a: ", toggled_on)
	
	if toggled_on:
		# Este modo fuerza al sistema a ignorar otras ventanas
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	Config.pantalla_completa = toggled_on
	Config.guardar_configuracion()


func _on_h_slider_value_changed(value: float) -> void:
	# 1. Cambiar el volumen real en el AudioServer
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	# 2. Guardar en el Autoload para que sea persistente
	Config.volumen_musica = value
	Config.guardar_configuracion()

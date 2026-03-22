extends CanvasLayer

# Usamos exactamente tu ruta existente
const SAVE_PATH = "user://config.cfg"

@onready var check_box = $TextureRect/VBoxContainer/CheckNoMostrar
@onready var btn_entendido = $TextureRect/VBoxContainer/BtnEntendido


func _ready():
	# Esto asegura que el mouse aparezca SIEMPRE que se abra esta ventana
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	# 2. CARGAR EL ESTADO DEL CHECKBOX
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
		# Leemos el valor. Si es 'false', significa que el usuario marcó "No mostrar"
		var mostrar = config.get_value("Interfaz", "mostrar_splash", true)
		
		# Si 'mostrar' es false, ponemos el CheckBox como activado
		if mostrar == false:
			check_box.button_pressed = true

func _on_btn_entendido_pressed() -> void:
	var config = ConfigFile.new()
	config.load(SAVE_PATH) #
	
	# LÓGICA DE ACTUALIZACIÓN:
	# Si el check está marcado -> Guardamos false (No mostrar)
	# Si el check NO está marcado -> Guardamos true (Sí mostrar)
	if check_box.button_pressed:
		config.set_value("Interfaz", "mostrar_splash", false) #
	else:
		config.set_value("Interfaz", "mostrar_splash", true) #
		
	config.save(SAVE_PATH) #
	
	get_tree().paused = false #
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #
	queue_free() #

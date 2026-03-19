extends CanvasLayer

# Usamos las rutas exactas de tu árbol de escenas (Mayúsculas importan)
@onready var btn_continuar = $Control/Continuar
@onready var btn_salir = $Control/Salir

func _ready():
	# Detenemos el tiempo para el Splash
	Engine.time_scale = 0.1 
	
	# --- SEÑALES DE CONTINUAR ---
	btn_continuar.mouse_entered.connect(_on_continuar_hover)
	btn_continuar.mouse_exited.connect(_on_continuar_normal)
	btn_continuar.gui_input.connect(_on_continuar_click)
	
	# --- SEÑALES DE SALIR ---
	btn_salir.mouse_entered.connect(_on_salir_hover)
	btn_salir.mouse_exited.connect(_on_salir_normal)
	btn_salir.gui_input.connect(_on_salir_click)

# --- FUNCIONES CONTINUAR ---
func _on_continuar_hover():
	btn_continuar.modulate = Color(0, 1, 0) # Solo verde para continuar

func _on_continuar_normal():
	btn_continuar.modulate = Color(1, 1, 1) # Vuelve a blanco

func _on_continuar_click(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Engine.time_scale = 1.0
		get_tree().change_scene_to_file("res://scenes/menu_inicio.tscn")

# --- FUNCIONES SALIR ---
func _on_salir_hover():
	btn_salir.modulate = Color(1, 0, 0) # Solo rojo para salir

func _on_salir_normal():
	btn_salir.modulate = Color(1, 1, 1) # Vuelve a blanco

func _on_salir_click(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().quit()

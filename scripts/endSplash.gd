extends CanvasLayer

# 1. Ajustamos las rutas. Ahora son hijos directos del CanvasLayer
@onready var color_rect = $ColorRect
@onready var menu_fondo = $TextureRect
@onready var btn_reintentar = $TextureRect/VBoxContainer/HBoxContainer/BtnReintentar
@onready var btn_salir = $TextureRect/VBoxContainer/HBoxContainer/BtnSalir

func _ready():
	# Configuración inicial
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	
	# Animación de entrada
	var tween = create_tween()
	
	# CORRECCIÓN AQUÍ: Quitamos el "../" porque ColorRect es hijo directo
	tween.tween_property(color_rect, "modulate:a", 0.6, 0.5) 
	
	# Animamos el menú
	tween.tween_property(menu_fondo, "modulate:a", 1.0, 0.5)

# --- FUNCIONES PARA REINTENTAR ---

func _on_btn_reintentar_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_btn_reintentar_mouse_entered():
	btn_reintentar.modulate = Color.GREEN

func _on_btn_reintentar_mouse_exited():
	btn_reintentar.modulate = Color.WHITE

# --- FUNCIONES PARA SALIR ---

func _on_btn_salir_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_inicio.tscn")

func _on_btn_salir_mouse_entered():
	btn_salir.modulate = Color.RED

func _on_btn_salir_mouse_exited():
	btn_salir.modulate = Color.WHITE

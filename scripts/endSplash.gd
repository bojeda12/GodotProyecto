extends Control

func _ready():
# 1. Configuramos el estado inicial
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	
	# 2. Creamos el Tween (el motor de la animación)
	var tween = create_tween()
	
	# Hacemos que el filtro negro aparezca en 0.5 segundos
	tween.tween_property($"../ColorRect", "modulate:a", 0.6, 0.5) 
	
	# Hacemos que el menú (imagen y botones) aparezca justo después
	tween.tween_property($Control, "modulate:a", 1.0, 0.5)
	

# --- BOTÓN REINTENTAR ---
func _on_reintentar_mouse_entered():
	$Reintentar.modulate = Color.GREEN # Se pone verde al pasar el mouse

func _on_reintentar_mouse_exited():
	$Reintentar.modulate = Color.WHITE # Vuelve a la normalidad

func _on_reintentar_gui_input(event):
# Si hace clic izquierdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().paused = false # ¡MUY IMPORTANTE quitar la pausa!
		get_tree().reload_current_scene() # Reinicia el nivel

# --- BOTÓN FINALIZAR ---
func _on_finalizar_mouse_entered():
	$Finalizar.modulate = Color.RED # Puedes ponerlo rojo o el color que quieras

func _on_finalizar_mouse_exited():
	$Finalizar.modulate = Color.WHITE

func _on_finalizar_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menu_inicio.tscn") # Ajusta tu ruta

extends Node2D

@export var bala_scene = preload("res://scenes/2/AguaDisparo.tscn")
@export var direccion_disparo = Vector2.DOWN # Asegúrate que en el inspector NO sea (0,0)
@onready var punto_salida = $PuntoSalida

func _on_timer_disparo_timeout():
	var nueva_bala = bala_scene.instantiate()
	
	# 1. Posición
	nueva_bala.global_position = punto_salida.global_position
	
	# 2. Dirección (Esto activará el 'set' en la bala y la rotará)
	nueva_bala.direccion = direccion_disparo
	
	# 3. Añadir al mundo
	get_tree().current_scene.add_child(nueva_bala)

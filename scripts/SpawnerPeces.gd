extends Node2D

@export var pez_escena: PackedScene 
@export var radio_generacion = 50.0 # Un poco más de espacio para que no se amontonen
@export var limite_global = 25 # limite de peces


#variable que permite activar o desactivar los spawner
var generacion_activa = true

func detener_generacion():
	generacion_activa = false
	print("Misión cumplida: Spawner desactivado.")
	
func _on_timer_timeout():
	# 1. Verificación de seguridad
	if not is_inside_tree() or get_tree() == null:
		return
	
	# --- NUEVA CONDICIÓN ---
	# Si la generación no está activa, no hacemos nada y salimos
	if not generacion_activa:
		return

	# 2. Tu retraso aleatorio actual
	await get_tree().create_timer(randf_range(0.1, 0.8)).timeout
	if get_tree() == null:
		return
	
	# 3. Verificación de grupo
	var peces_vivos = get_tree().get_nodes_in_group("enemigos").size()
	
	if peces_vivos < limite_global:
		generar_pez()
	#else:
		#print("Límite de ", limite_global, " peces alcanzado. Total actual: ", peces_vivos)

#func generar_pez():
	#if pez_escena:
		## 1. Calculamos la posición potencial
		#var offset = Vector2(randf_range(-radio_generacion, radio_generacion), randf_range(-radio_generacion, radio_generacion))
		#var posicion_objetivo = global_position + offset
		#
		## 2. Verificamos si hay espacio vacío
		#if posicion_esta_libre(posicion_objetivo):
			#var nuevo_pez = pez_escena.instantiate()
			#nuevo_pez.add_to_group("enemigos")
			#nuevo_pez.global_position = posicion_objetivo
			#get_tree().current_scene.add_child(nuevo_pez)
		##else:
			## Si está ocupado, podemos intentar de nuevo en el siguiente timeout
			##print("Posición ocupada por un tile, cancelando generación")
func generar_pez():
	if pez_escena:
		var offset = Vector2(randf_range(-radio_generacion, radio_generacion), randf_range(-radio_generacion, radio_generacion))
		var posicion_objetivo = global_position + offset
		
		if posicion_esta_libre(posicion_objetivo):
			var nuevo_pez = pez_escena.instantiate()
			nuevo_pez.add_to_group("enemigos")
			nuevo_pez.global_position = posicion_objetivo
			get_tree().current_scene.add_child(nuevo_pez)
			
			# --- PECES DE COLORES ALEATORIOS ---
			var colores = [
				Color(1, 1, 1),      # Blanco (Mantiene el VERDE original del sprite)
				Color(0.941, 0.0, 0.451, 1.0),    # NARANJA
				Color(0.0, 0.231, 0.878, 1.0)   # AZUL
			]
			
			# Elegimos uno al azar de la lista
			var color_elegido = colores[randi() % colores.size()]
			
			# Se lo aplicamos al pez (esperamos un frame para asegurar que el pez esté listo)
			if nuevo_pez.has_method("cambiar_color"):
				nuevo_pez.cambiar_color(color_elegido)

# Función auxiliar para detectar colisiones antes de spawnear
func posicion_esta_libre(pos):
	var espacio = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1 # Asegúrate de que este sea el mismo ID de capa de tus Tiles
	
	var resultado = espacio.intersect_point(query)
	return resultado.is_empty() # Retorna true si no hay nada en ese punto

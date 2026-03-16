extends Node2D

@export var pez_escena: PackedScene 
@export var radio_generacion = 50.0 # Un poco más de espacio para que no se amontonen
@export var limite_global = 30 # Ahora es más fácil cambiar el número desde el Inspector

func _on_timer_timeout():
	# 1. Verificación de seguridad: ¿Existe todavía el mundo?
	if not is_inside_tree() or get_tree() == null:
		return
	# 2. RETRASO ALEATORIO: Evita que los 4 spawners actúen al mismo milisegundo
	await get_tree().create_timer(randf_range(0.1, 0.8)).timeout
	if get_tree() == null:
		return
	
	# 2. VERIFICACIÓN DEL GRUPO: Contamos cuántos peces "etiquetados" hay
	var peces_vivos = get_tree().get_nodes_in_group("enemigos").size()
	
	# 3. DECISIÓN: Solo si hay espacio, llamamos a la función de generar
	if peces_vivos < limite_global:
		generar_pez()
	else:
		print("Límite de ", limite_global, " peces alcanzado. Total actual: ", peces_vivos)

func generar_pez():
	if pez_escena:
		# 1. Calculamos la posición potencial
		var offset = Vector2(randf_range(-radio_generacion, radio_generacion), randf_range(-radio_generacion, radio_generacion))
		var posicion_objetivo = global_position + offset
		
		# 2. Verificamos si hay espacio vacío
		if posicion_esta_libre(posicion_objetivo):
			var nuevo_pez = pez_escena.instantiate()
			nuevo_pez.add_to_group("enemigos")
			nuevo_pez.global_position = posicion_objetivo
			get_tree().current_scene.add_child(nuevo_pez)
		else:
			# Si está ocupado, podemos intentar de nuevo en el siguiente timeout
			print("Posición ocupada por un tile, cancelando generación")

# Función auxiliar para detectar colisiones antes de spawnear
func posicion_esta_libre(pos):
	var espacio = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1 # Asegúrate de que este sea el mismo ID de capa de tus Tiles
	
	var resultado = espacio.intersect_point(query)
	return resultado.is_empty() # Retorna true si no hay nada en ese punto

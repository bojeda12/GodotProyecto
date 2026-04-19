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
	# 1. Verificación de seguridad
	if not pez_escena: 
		return
	
	var posicion_final = Vector2.ZERO
	var encontrado = false
	
	# 2. BUCLE DE BÚSQUEDA: Intentamos hasta 5 veces encontrar un hueco libre
	# Esto evita que el pez aparezca dentro de los tiles
	for i in range(5):
		# Usamos coordenadas polares para una dispersión circular perfecta
		var angulo = randf() * TAU
		# La raíz cuadrada de randf ayuda a que se dispersen más hacia los bordes
		var distancia = sqrt(randf()) * radio_generacion
		var intento_pos = global_position + Vector2(cos(angulo), sin(angulo)) * distancia
		
		# Verificamos si el área está libre de paredes (usando la función que creamos antes)
		if posicion_esta_libre(intento_pos):
			posicion_final = intento_pos
			encontrado = true
			break # Si encontramos sitio, dejamos de buscar
	
	# 3. INSTANCIACIÓN: Solo si encontramos un lugar válido
	if encontrado:
		var nuevo_pez = pez_escena.instantiate()
		
		# Añadir al grupo para que cuente en el límite global y para colisiones
		nuevo_pez.add_to_group("enemigos")
		
		# Colocamos al pez en la posición libre encontrada
		nuevo_pez.global_position = posicion_final
		
		# Lo añadimos a la escena principal
		get_tree().current_scene.add_child(nuevo_pez)
		
		# 4. LÓGICA DE COLORES ALEATORIOS
		var colores = [
			Color(1, 1, 1),           # Blanco/Original
			Color(0.941, 0.0, 0.451), # Naranja/Rosa fuerte
			Color(0.0, 0.231, 0.878), # Azul
			Color(1, 0.84, 0)         # Dorado (opcional, para variar)
		]
		
		# Elegimos un color al azar
		var color_elegido = colores[randi() % colores.size()]
		
		# Aplicamos el color al Sprite del pez
		# Nota: Asegúrate de que el script de tu pez tenga la función 'cambiar_color'
		if nuevo_pez.has_method("cambiar_color"):
			nuevo_pez.cambiar_color(color_elegido)
		else:
			# Si no quieres crear una función en el pez, puedes intentar acceder directo al sprite
			# Supongando que el pez tiene un AnimatedSprite2D llamado 'AnimatedSprite2D'
			var sprite_pez = nuevo_pez.get_node_or_null("AnimatedSprite2D")
			if sprite_pez:
				sprite_pez.modulate = color_elegido

# Función auxiliar para detectar colisiones antes de spawnear
func posicion_esta_libre(pos):
	var espacio = get_world_2d().direct_space_state
	
	# Creamos una forma circular para "probar" el espacio antes de meter al pez
	var forma_circulo = CircleShape2D.new()
	forma_circulo.radius = 15.0 # Ajusta esto al tamaño de tus peces (un poco más grande es mejor)
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = forma_circulo
	query.transform = Transform2D(0, pos)
	query.collision_mask = 1 # Revisa la Capa 1 (donde están tus Tiles/paredes)
	
	var resultado = espacio.intersect_shape(query)
	return resultado.is_empty() # Si el círculo toca una pared, retorna false

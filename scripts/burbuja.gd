extends Area2D

# --- VARIABLES NORMALES ---
var velocidad = 400
var direccion = Vector2.UP

# --- NUEVAS VARIABLES PARA ESPIRAL ---
var modo_espiral = false
var angulo_actual = 0.0
var radio = 0.0
var velocidad_expansion = 200.0 
var velocidad_giro = 5.0        
var centro_espiral = Vector2.ZERO
var escala_inicial = 1.0 # Para guardar el tamaño original

func configurar_espiral(p_angulo, p_vel_exp, p_vel_giro):
	modo_espiral = true
	angulo_actual = p_angulo
	velocidad_expansion = p_vel_exp
	velocidad_giro = p_vel_giro
	centro_espiral = global_position
	escala_inicial = scale.x # Guardamos si la burbuja era grande o pequeña

func _physics_process(delta):
	if modo_espiral:
		# 1. Girar y alejarse
		angulo_actual += velocidad_giro * delta
		radio += velocidad_expansion * delta
		
		# 2. EFECTO DE TAMAÑO: Se encoge conforme se aleja
		# El número 600 es la distancia máxima; si llega ahí, la escala será 0
		var nueva_escala = lerp(escala_inicial, 0.0, radio / 600.0)
		scale = Vector2(nueva_escala, nueva_escala)
		
		# Si ya es demasiado pequeña, la borramos para ahorrar memoria
		if nueva_escala <= 0.05:
			queue_free()
		
		# 3. Posicionamiento
		var nueva_pos = Vector2(cos(angulo_actual), sin(angulo_actual)) * radio
		global_position = centro_espiral + nueva_pos
		rotation = angulo_actual + PI/2
	else:
		# Movimiento normal de la boca
		position += direccion * velocidad * delta

# --- LIMPIEZA AUTOMÁTICA (Fuera de cámara) ---

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Esto es vital para que no se vayan al infinito
	queue_free() 

func _on_body_entered(body):
	if body.name == "Player":
		return 
	
	if body.has_method("recibir_danio"):
		# Aquí puedes añadir una pequeña explosión o sonido
		body.recibir_danio(1)
		queue_free()
	
	elif body is TileMap:
		queue_free()

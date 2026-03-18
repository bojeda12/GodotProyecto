extends Area2D

# --- VARIABLES NORMALES ---
var velocidad = 400
var direccion = Vector2.UP

# --- NUEVAS VARIABLES PARA ESPIRAL (Por defecto desactivadas) ---
var modo_espiral = false
var angulo_actual = 0.0
var radio = 0.0
var velocidad_expansion = 200.0 # Qué tan rápido se aleja
var velocidad_giro = 5.0        # Qué tan rápido da vueltas
var centro_espiral = Vector2.ZERO

# Esta función la llamaremos desde el Player solo para el ataque especial
func configurar_espiral(p_angulo, p_vel_exp, p_vel_giro):
	modo_espiral = true
	angulo_actual = p_angulo
	velocidad_expansion = p_vel_exp
	velocidad_giro = p_vel_giro
	centro_espiral = global_position # El punto donde nació el ataque

func _physics_process(delta):
	if modo_espiral:
		# --- MOVIMIENTO EN ESPIRAL ---
		angulo_actual += velocidad_giro * delta
		radio += velocidad_expansion * delta
		
		# Matemáticas para el círculo que se expande
		var nueva_pos = Vector2(
			cos(angulo_actual),
			sin(angulo_actual)
		) * radio
		
		global_position = centro_espiral + nueva_pos
		rotation = angulo_actual + PI/2
	else:
		# --- MOVIMIENTO NORMAL (Boca) ---
		position += direccion * velocidad * delta

# --- DETECCIÓN DE COLISIONES (Igual que antes) ---

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		return 
	
	if body.has_method("recibir_danio"):
		print("¡Impacto en el pez!")
		body.recibir_danio(1)
		queue_free()
	
	elif body is TileMap:
		print("Chocó con pared")
		queue_free()

func destruir_burbuja():
	queue_free()

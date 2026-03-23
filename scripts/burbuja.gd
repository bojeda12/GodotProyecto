extends Area2D

# --- VARIABLES DE AUDIO DINÁMICO ---
var ruta_sonido = "res://musica/DisparoEspiralOnda.mp3" # Sonido por defecto
@onready var sonido_burbuja = AudioStreamPlayer2D.new()

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
var escala_inicial = 1.0 

func _ready():
	add_child(sonido_burbuja)
	var audio = load(ruta_sonido)
	if audio:
		sonido_burbuja.stream = audio
		sonido_burbuja.bus = "SFX" 
		sonido_burbuja.play()
	
func configurar_espiral(p_angulo, p_vel_exp, p_vel_giro):
	modo_espiral = true
	angulo_actual = p_angulo
	velocidad_expansion = p_vel_exp
	velocidad_giro = p_vel_giro
	centro_espiral = global_position
	escala_inicial = scale.x 

func _physics_process(delta):
	if modo_espiral:
		angulo_actual += velocidad_giro * delta
		radio += velocidad_expansion * delta
		
		var nueva_escala = lerp(escala_inicial, 0.0, radio / 600.0)
		scale = Vector2(nueva_escala, nueva_escala)
		
		if nueva_escala <= 0.05:
			limpiar_burbuja()
		
		var nueva_pos = Vector2(cos(angulo_actual), sin(angulo_actual)) * radio
		global_position = centro_espiral + nueva_pos
		rotation = angulo_actual + PI/2
	else:
		position += direccion * velocidad * delta

# --- FUNCIÓN DE LIMPIEZA ---
# Esto asegura que el sonido se detenga antes de borrar el nodo
func limpiar_burbuja():
	if sonido_burbuja.playing:
		sonido_burbuja.stop()
	queue_free()

# --- DETECCIÓN Y COLISIONES ---

func _on_visible_on_screen_notifier_2d_screen_exited():
	limpiar_burbuja()

func _on_body_entered(body):
	if body.name == "Player":
		return 
	
	if body.has_method("recibir_danio"):
		body.recibir_danio(1)
		limpiar_burbuja()
	
	elif body is TileMap:
		limpiar_burbuja()

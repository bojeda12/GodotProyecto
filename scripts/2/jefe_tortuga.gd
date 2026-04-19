extends CharacterBody2D

# --- Variables de Salud y Estado ---
var salud_max = 300
var salud_actual = 300
var fase = 1

# --- Variables de Movimiento ---
@export var velocidad_base = 100.0
var direccion_random = Vector2.ZERO # Se usa para Fase 1 y Fase 3
var direccion_rebote = Vector2(1, 1).normalized() # Para Fase 2 (Pinpón)

@onready var jugador = get_tree().get_first_node_in_group("jugador")
@onready var sprite = $AnimatedSprite2D
@onready var barra_vida = $HUD_jefe/Barravida

# --- NUEVO: Escena del Pez Naranja ---
@export var pez_salud_escena: PackedScene = preload("res://scenes/2/pezNaranja.tscn")

# --- Control de Ciclos de Fase 2 ---
var timer_ciclo_fase2 = 0.0
var alternar_rebote = true 

# --- Disparo ---
@export var espina_escena: PackedScene = preload("res://scenes/2/AguaDisparo.tscn")
var timer_ataque = 0.0

func _ready():
	add_to_group("jefe") # Para que las balas no lo dañen
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	sprite.play("idle")
	salud_actual = salud_max
	barra_vida.max_value = 100
	barra_vida.value = 100
	randomize()
	elegir_nueva_direccion_random() # Dirección inicial

func _physics_process(delta):
	if salud_actual > 0:
		
		# --- GESTIÓN DE DISPARO ---
		# Dispara siempre, excepto cuando está rebotando en Fase 2
		if fase == 1 or fase == 3 or (fase == 2 and not alternar_rebote):
			timer_ataque += delta
			if timer_ataque >= 2.5 and timer_ataque < 2.6: 
				preparar_aviso_visual()
			if timer_ataque >= 3.0:
				lanzar_espinas()
				timer_ataque = 0.0
		
		# --- LÓGICA DE MOVIMIENTO ---
		match fase:
			1:
				# Movimiento aleatorio LENTO
				ejecutar_movimiento_random(delta, 1.5) 
			2:
				manejar_ciclos_fase2(delta)
				if alternar_rebote:
					ejecutar_movimiento_rebote(delta)
				else:
					# En el descanso de la fase 2, se mueve lento aleatorio
					ejecutar_movimiento_random(delta, 0.8)
			3:
				# Movimiento aleatorio RÁPIDO
				ejecutar_movimiento_random(delta, 2.8)
			
		actualizar_mirada()

# --- FUNCIÓN UNIFICADA DE MOVIMIENTO ALEATORIO ---
func ejecutar_movimiento_random(delta, multiplicador_velocidad):
	var v_final = velocidad_base * multiplicador_velocidad
	var colision = move_and_collide(direccion_random * v_final * delta)
	
	# Si choca con un tile o pared, cambia a una dirección RANDOM
	if colision:
		elegir_nueva_direccion_random()

func elegir_nueva_direccion_random():
	var angulo = randf_range(0, 2 * PI)
	direccion_random = Vector2(cos(angulo), sin(angulo)).normalized()

# --- CICLOS FASE 2 (PINPÓN) ---
func manejar_ciclos_fase2(delta):
	timer_ciclo_fase2 += delta
	if alternar_rebote:
		if timer_ciclo_fase2 >= 10.0:
			alternar_rebote = false
			timer_ciclo_fase2 = 0.0
			sprite.play("idle")
			create_tween().tween_property(self, "scale", Vector2(1, 1), 0.5)
	else:
		if timer_ciclo_fase2 >= 20.0:
			alternar_rebote = true
			timer_ciclo_fase2 = 0.0
			sprite.play("inflado")
			create_tween().tween_property(self, "scale", Vector2(1.6, 1.6), 0.5)

func ejecutar_movimiento_rebote(delta):
	var v_rebote = velocidad_base * 2.8 
	if sprite.animation == "inflado":
		if sprite.frame >= 4:
			sprite.stop() 
			sprite.frame = 4
		else:
			if not sprite.is_playing():
				sprite.play("inflado")

	var colision = move_and_collide(direccion_rebote * v_rebote * delta)
	if colision:
		direccion_rebote = direccion_rebote.bounce(colision.get_normal())

# --- ATAQUES ---
func lanzar_espinas():
	var cantidad = 12 if fase == 1 else 16
	var escala = Vector2(1, 1) if fase == 1 else Vector2(2.2, 2.2)
	var separacion = 100.0 # Mantenemos tu separación original
	
	for i in range(cantidad):
		var nueva_espina = espina_escena.instantiate()
		var angulo = i * (2 * PI / cantidad)
		var dir = Vector2(cos(angulo), sin(angulo))
		nueva_espina.global_position = global_position + (dir * separacion)
		nueva_espina.direccion = dir
		nueva_espina.rotation = angulo
		nueva_espina.scale = escala
		get_parent().add_child(nueva_espina)
		if fase == 3:
			nueva_espina.modulate = Color(2, 0.5, 0.5)

func preparar_aviso_visual():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "modulate", Color(4, 4, 4), 0.2)
	for i in range(5):
		tween.chain().tween_property(sprite, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.05)
	tween.chain().tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)
	tween.tween_property(sprite, "offset", Vector2.ZERO, 0.1)

# --- DAÑO Y FASES ---
func recibir_danio(cantidad):
	if fase == 2 and alternar_rebote: return 
	salud_actual -= cantidad * 5
	var porcentaje_vida = (float(salud_actual) / salud_max) * 100
	create_tween().tween_property(barra_vida, "value", porcentaje_vida, 0.2)
	
	sprite.modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	actualizar_fase()

func actualizar_fase():
	var porcentaje = (float(salud_actual) / salud_max) * 100
	if salud_actual <= 0:
		morir()
	elif porcentaje <= 25 and fase != 3:
		fase = 3
		alternar_rebote = false 
		scale = Vector2(1, 1) 
		sprite.play("furia")
		sprite.modulate = Color(1.5, 0.5, 0.5)
		get_tree().call_group("anemonas", "activar_anemona")
		
		# Generamos el pez de ayuda al entrar en Fase 3
		aparecer_pez_ayuda()

	elif porcentaje <= 65 and fase == 1:
		fase = 2
		alternar_rebote = true
		timer_ciclo_fase2 = 0.0
		sprite.play("inflado")
		create_tween().tween_property(self, "scale", Vector2(1.6, 1.6), 0.5)

# --- FUNCIÓN PARA EL PEZ ---
func aparecer_pez_ayuda():
	if pez_salud_escena:
		var pez = pez_salud_escena.instantiate()
		# Lo pone en una posición aleatoria cerca del centro de la pelea
		var offset_random = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		pez.global_position = global_position + offset_random
		get_parent().add_child(pez)

func morir():
	salud_actual = 0
	barra_vida.value = 0
	set_physics_process(false)
	sprite.play("morir")
	await sprite.animation_finished
	soltar_recompensa()
	queue_free()

func soltar_recompensa():
	var llave_scene = load("res://scenes/item_llave.tscn")
	if llave_scene:
		var nueva_llave = llave_scene.instantiate()
		get_parent().add_child(nueva_llave)
		nueva_llave.global_position = global_position
		nueva_llave.es_llave_final = true
		
		# --- DETECCIÓN POR ARCHIVO .TSCN ---
		var ruta_archivo = get_tree().current_scene.scene_file_path
		
		if "res://scenes/Enemigo_final1.tscn" in ruta_archivo:
			nueva_llave.escena_siguiente_nivel = "res://scenes/2/game2.tscn"
		elif "res://scenes/2/Enemigo_final2.tscn" in ruta_archivo:
			nueva_llave.escena_siguiente_nivel = "res://scenes/3/game3.tscn"
		else:
			nueva_llave.escena_siguiente_nivel = "res://scenes/2/game2.tscn"

func actualizar_mirada():
	# Mirar siempre hacia donde se mueve
	if fase == 2 and alternar_rebote:
		sprite.flip_h = direccion_rebote.x < 0
	else:
		sprite.flip_h = direccion_random.x < 0

func _on_zona_danina_body_entered(body):
	if body.is_in_group("jugador"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(1)
			var dir_empuje = (body.global_position - global_position).normalized()
			body.velocity = dir_empuje * 600

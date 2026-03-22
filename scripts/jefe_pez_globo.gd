extends CharacterBody2D

# --- Variables de Salud y Estado ---
var salud_max = 300
var salud_actual = 300
var fase = 1

# --- Variables de Movimiento ---
@export var velocidad_base = 100.0
@export var distancia_patrullaje = 200.0
var posicion_inicial: Vector2
var moviendo_a_derecha = true

@onready var jugador = get_tree().get_first_node_in_group("jugador")
@onready var sprite = $AnimatedSprite2D

#Barra de vida
@onready var barra_vida = $HUD_jefe/Barravida

#disparo
@export var espina_escena: PackedScene = preload("res://scenes/espina.tscn")
var timer_ataque = 0.0


func _ready():
	posicion_inicial = global_position
	sprite.play("idle")
	salud_actual = salud_max
	
	# --- AJUSTE PARA EL PORCENTAJE ---
	barra_vida.max_value = 100  # La barra ahora escala de 0 a 100%
	barra_vida.value = 100      # Empieza llena
	
	print("Barra del jefe lista al 100%")
	

func _physics_process(delta):
	if salud_actual > 0:
		# Temporizador de disparo
		timer_ataque += delta
		
		# --- NUEVO: AVISO VISUAL (Se activa 0.5 segundos antes de disparar) ---
		# Si falta poco para los 3.0 segundos, avisamos al jugador
		if timer_ataque >= 2.5 and timer_ataque < 2.6: 
			preparar_aviso_visual()

		# Disparo original
		if timer_ataque >= 3.0:
			lanzar_espinas()
			timer_ataque = 0.0
		
		ejecutar_comportamiento(delta)
		actualizar_mirada()

# --- NUEVA FUNCIÓN PARA EL EFECTO DE TEMBLOR Y BRILLO ---
func preparar_aviso_visual():
	var tween = create_tween().set_parallel(true)
	var sprite = $AnimatedSprite2D # Asegúrate de que este sea el nombre de tu nodo de imagen
	
	# 1. Brillo intenso (Flash blanco)
	tween.tween_property(sprite, "modulate", Color(4, 4, 4), 0.2)
	
	# 2. Temblor (Sacudida rápida)
	for i in range(5):
		tween.chain().tween_property(sprite, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.05)
	
	# 3. Volver a la normalidad justo antes de que salgan las espinas
	tween.chain().tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)
	tween.tween_property(sprite, "offset", Vector2.ZERO, 0.1)
	
	
func lanzar_espinas():
	# Valores por defecto (Fase 1)
	var cantidad_espinas = 8
	var tamaño_espina = Vector2(1, 1)
	
	# Ajustamos según la fase actual
	if fase == 2:
		cantidad_espinas = 12 # Más espinas
		tamaño_espina = Vector2(1.5, 1.5) # Un poco más grandes
	elif fase == 3:
		cantidad_espinas = 16 # ¡Lluvia de espinas!
		tamaño_espina = Vector2(2.2, 2.2) # Espinas gigantes
	
	# Bucle de disparo actualizado
	for i in range(cantidad_espinas):
		var nueva_espina = espina_escena.instantiate()
		get_parent().add_child(nueva_espina)
		nueva_espina.global_position = global_position
		
		# Calculamos el ángulo dinámicamente según la cantidad
		var angulo = i * (2 * PI / cantidad_espinas) 
		nueva_espina.direccion = Vector2(cos(angulo), sin(angulo))
		nueva_espina.rotation = angulo
		
		# Aplicamos el tamaño a la espina
		nueva_espina.scale = tamaño_espina
		
	
		if fase == 3:
			# El color (2, 0.5, 0.5) hace que brille (Bloom) si tienes WorldEnvironment
			nueva_espina.modulate = Color(2, 0.5, 0.5) 
			# Opcional: Que las espinas de fase 3 sean un poco más rápidas
			if "velocidad" in nueva_espina:
				nueva_espina.velocidad = 350

func ejecutar_comportamiento(delta):
	# 1. Ajustar velocidad según la fase (Limpiamos los if y aseguramos valor)
	var v_act = velocidad_base # Usamos un nombre corto para evitar errores
	
	if fase == 2:
		v_act = velocidad_base * 0.6
	elif fase == 3:
		v_act = velocidad_base * 2.5
	else:
		v_act = velocidad_base
	
	# 2. Aplicar la dirección a la velocidad
	if moviendo_a_derecha:
		velocity.x = v_act
	else:
		velocity.x = -v_act
	
	# 3. Movimiento Vertical Ondulado
	velocity.y = sin(Time.get_ticks_msec() * 0.002) * 70
	
	# 4. Mover y Rebotar
	move_and_slide()
	
	# Si toca pared, cambia de dirección
	if is_on_wall():
		moviendo_a_derecha = !moviendo_a_derecha
		# Separar un poco del muro para evitar que se atore
		if moviendo_a_derecha:
			global_position.x += 5
		else:
			global_position.x -= 5

func actualizar_mirada():
	# Si se mueve a la derecha (velocity.x > 0)
	if velocity.x > 0:
		sprite.flip_h = false  # <--- Cámbialo a 'false' si antes era 'true'
	# Si se mueve a la izquierda (velocity.x < 0)
	elif velocity.x < 0:
		sprite.flip_h = true   # <--- Cámbialo a 'true' si antes era 'false'
		
func recibir_danio(cantidad):
	# 1. Aplicamos el daño (manteniendo tu multiplicador de testeo)
	var daño_final = cantidad * 5
	salud_actual -= daño_final
	
	# --- SOLUCIÓN VERGA: CÁLCULO PORCENTUAL ---
	# Esto convierte la salud (0 a 300) en un valor de 0 a 100 para la barra.
	# Así, aunque la salud sea 55, la barra marcará 18.3% y SE SEGUIRÁ VIENDO.
	var porcentaje_vida = (float(salud_actual) / salud_max) * 100
	
	# Actualizamos la barra usando el porcentaje calculado
	# Usamos un Tween para que el movimiento sea fluido y no de saltos
	var tween_barra = create_tween()
	tween_barra.tween_property(barra_vida, "value", porcentaje_vida, 0.2).set_trans(Tween.TRANS_SINE)
	
	# Debug para confirmar que los números cuadran
	print("Jefe -> Salud Real: ", salud_actual, " | Visual en Barra: ", porcentaje_vida, "%")
	
	# 2. Efecto visual de parpadeo (Tu lógica original)
	sprite.modulate = Color(10, 10, 10) 
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1) 
	
	# 3. Revisar cambios de fase o muerte
	actualizar_fase()

func actualizar_fase():
	if salud_actual <= 0:
		morir()
		return
	elif salud_actual <= 100:
		if fase != 3:
			fase = 3
			sprite.play("furia")
			# En furia, se pone rojo
			sprite.modulate = Color(1.5, 0.5, 0.5) 
	elif salud_actual <= 200:
		if fase != 2:
			fase = 2
			sprite.play("inflado")
			# --- EFECTO DE INFLADO ---
			var tween = create_tween()
			# Se hace un 50% más grande en 0.5 segundos
			tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.5)

func morir():
	salud_actual = 0
	barra_vida.value = 0
	set_physics_process(false) # Se detiene el movimiento
	
	# Efecto de vibración y destello
	var tween = create_tween()
	for i in range(5):
		tween.tween_property(sprite, "position", Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.05)
		tween.tween_property(sprite, "modulate", Color(10, 10, 10), 0.05)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.05)
	
	sprite.play("morir")
	print("¡Victoria!")
	
	await sprite.animation_finished
	# Soltar el premio (La llave final o el tesoro)
	soltar_recompensa()
	queue_free()

func soltar_recompensa():
	var llave_scene = load("res://scenes/item_llave.tscn")
	if llave_scene:
		var nueva_llave = llave_scene.instantiate()
		get_parent().add_child(nueva_llave)
		nueva_llave.global_position = global_position
		
		# --- AQUÍ ACTIVAMOS LA MAGIA ---
		# Le decimos a esta instancia específica que SÍ es la final
		#if "es_llave_final" in nueva_llave:
			#nueva_llave.es_llave_final = true
		nueva_llave.es_llave_final = true 
		print("Soltando llave FINAL")


func _on_zona_danina_body_entered(body):
	# Si el cuerpo que entró es el Ajolote (que debe estar en el grupo "jugador")
	if body.is_in_group("jugador"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(1) # O la cantidad de vida que quieras quitarle
			
			# EFECTO DE EMPUJE (Knockback)
			# Calculamos la dirección desde el jefe hacia el jugador
			var direccion_empuje = (body.global_position - global_position).normalized()
			# Le damos un "golpe" físico al ajolote para que se aleje
			body.velocity = direccion_empuje * 500

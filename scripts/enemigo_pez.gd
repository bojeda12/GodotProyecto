extends CharacterBody2D

@export var velocidad: float = 80.0
@export var aceleracion: float = 500.0
@export var distancia_ataque: float = 25.0
@export var salud: int = 1
@export var distancia_patrullaje: float = 100.0
@export var duracion_busqueda: float = 1.0
@export var danio_ataque: float = 0.50

var posicion_inicial: Vector2 = Vector2.ZERO
var moviendo_a_derecha: bool = true
var ultima_posicion_vista: Vector2 = Vector2.ZERO
var tiempo_busqueda: float = 0.0

var jugador = null
var esta_muerto: bool = false
var esta_atacando: bool = false
var tiempo_cambio_pared: float = 0.0

@onready var sprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D
@onready var agente = $NavigationAgent2D

var punto_patrulla_izquierdo: Vector2
var punto_patrulla_derecho: Vector2
var objetivo_patrulla_actual: Vector2
var regresando_a_patrulla: bool = false

var burbuja_recolectable = preload("res://scenes/item_burbuja.tscn")

func _ready():
	add_to_group("enemigos")
	posicion_inicial = global_position
	ultima_posicion_vista = global_position
	sprite.play("nadar")

	punto_patrulla_izquierdo = Vector2(posicion_inicial.x - distancia_patrullaje, posicion_inicial.y)
	punto_patrulla_derecho = Vector2(posicion_inicial.x + distancia_patrullaje, posicion_inicial.y)
	objetivo_patrulla_actual = punto_patrulla_derecho if moviendo_a_derecha else punto_patrulla_izquierdo

	agente.path_desired_distance = 8.0
	agente.target_desired_distance = 8.0
	agente.avoidance_enabled = false

func _physics_process(delta):
	if esta_muerto or esta_atacando:
		return
	if tiempo_cambio_pared > 0.0:
		tiempo_cambio_pared -= delta

	if jugador != null and not is_instance_valid(jugador):
		jugador = null

	if jugador != null:
		raycast.target_position = to_local(jugador.global_position)
		raycast.force_raycast_update()

		var collider = raycast.get_collider()
		var ve_al_jugador = false

		if collider != null:
			if collider == jugador or collider.is_in_group("jugador"):
				ve_al_jugador = true

		if ve_al_jugador:
			regresando_a_patrulla = false
			ultima_posicion_vista = jugador.global_position
			tiempo_busqueda = duracion_busqueda
			perseguir_con_rodeo(jugador.global_position, delta)
		else:
			if tiempo_busqueda > 0.0:
				tiempo_busqueda -= delta
				perseguir_con_rodeo(ultima_posicion_vista, delta)
			else:
				if regresando_a_patrulla:
					mover_con_agente(objetivo_patrulla_actual, velocidad * 0.4, delta)

					if global_position.distance_to(objetivo_patrulla_actual) <= 10.0:
						regresando_a_patrulla = false
				else:
					ejecutar_patrullaje(delta)
	else:
		if regresando_a_patrulla:
			mover_con_agente(objetivo_patrulla_actual, velocidad * 0.4, delta)

			if global_position.distance_to(objetivo_patrulla_actual) <= 10.0:
				regresando_a_patrulla = false
		else:
			ejecutar_patrullaje(delta)

	revisar_colision_con_jugador()

func perseguir_con_rodeo(objetivo: Vector2, delta: float):
	var direccion = (objetivo - global_position).normalized()
	var velocidad_objetivo = direccion * velocidad

	velocity = velocity.move_toward(velocidad_objetivo, aceleracion * delta)
	move_and_slide()

	if is_on_wall() and get_real_velocity().length() < 5.0:
		var desvio_1 = Vector2(direccion.y, -direccion.x).normalized()
		var desvio_2 = Vector2(-direccion.y, direccion.x).normalized()

		var punto_1 = global_position + desvio_1 * 20.0
		var punto_2 = global_position + desvio_2 * 20.0

		if punto_1.distance_to(objetivo) <= punto_2.distance_to(objetivo):
			velocity = desvio_1 * velocidad
		else:
			velocity = desvio_2 * velocidad

		move_and_slide()

	if abs(velocity.x) > 0.05:
		sprite.flip_h = velocity.x < 0

	sprite.play("nadar")

func mover_con_agente(destino: Vector2, velocidad_movimiento: float, delta: float):
	agente.target_position = destino

	if agente.is_navigation_finished():
		velocity = velocity.move_toward(Vector2.ZERO, aceleracion * delta)
		move_and_slide()
		return

	var siguiente_punto = agente.get_next_path_position()
	var direccion = (siguiente_punto - global_position).normalized()
	var velocidad_objetivo = direccion * velocidad_movimiento

	velocity = velocity.move_toward(velocidad_objetivo, aceleracion * delta)
	move_and_slide()

	if abs(velocity.x) > 0.05:
		sprite.flip_h = velocity.x < 0

	sprite.play("nadar")

func hay_pared_enfrente(direccion_x: float) -> bool:
	if direccion_x == 0.0:
		return false

	var distancia_prueba = 10.0
	var movimiento_prueba = Vector2(sign(direccion_x) * distancia_prueba, 0.0)
	return test_move(global_transform, movimiento_prueba)

func ejecutar_patrullaje(delta: float):
	var limite_derecho = posicion_inicial.x + distancia_patrullaje
	var limite_izquierdo = posicion_inicial.x - distancia_patrullaje

	if moviendo_a_derecha and global_position.x >= limite_derecho:
		moviendo_a_derecha = false
	elif not moviendo_a_derecha and global_position.x <= limite_izquierdo:
		moviendo_a_derecha = true

	var direccion_x = 1.0 if moviendo_a_derecha else -1.0

	# Solo cambia de dirección una vez y le da tiempo a salir del muro
	if tiempo_cambio_pared <= 0.0 and hay_pared_enfrente(direccion_x):
		moviendo_a_derecha = !moviendo_a_derecha
		direccion_x = 1.0 if moviendo_a_derecha else -1.0
		tiempo_cambio_pared = 0.25
		velocity.x = direccion_x * velocidad * 0.4
	else:
		var velocidad_objetivo = Vector2(direccion_x * velocidad * 0.4, 0.0)
		velocity = velocity.move_toward(velocidad_objetivo, aceleracion * delta)

	if abs(velocity.x) > 0.05:
		sprite.flip_h = velocity.x < 0

	sprite.play("nadar")
	move_and_slide()

func revisar_colision_con_jugador():
	if jugador == null or not is_instance_valid(jugador):
		return
	if esta_atacando or esta_muerto:
		return

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var cuerpo = collision.get_collider()

		if cuerpo != null and is_instance_valid(cuerpo):
			if cuerpo == jugador or cuerpo.is_in_group("jugador"):
				lanzar_ataque(false)
				return

func lanzar_ataque(golpeo_escudo: bool = false):
	if esta_muerto or esta_atacando:
		return

	esta_atacando = true
	velocity = Vector2.ZERO

	if not golpeo_escudo and jugador != null:
		if jugador.has_method("recibir_danio"):
			jugador.recibir_danio(danio_ataque)

	sprite.play("atacar")

	await get_tree().create_timer(0.1).timeout

	morir_por_explosion()

func recibir_danio(cantidad):
	if esta_muerto:
		return

	salud -= cantidad

	if salud <= 0:
		morir()
	else:
		esta_atacando = true
		velocity = Vector2.ZERO
		sprite.play("herido")
		await sprite.animation_finished
		esta_atacando = false

		if not esta_muerto:
			sprite.play("nadar")

func morir():
	if esta_muerto:
		return

	esta_muerto = true
	esta_atacando = false

	set_physics_process(false)
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)

	sprite.stop()
	sprite.frame = 0
	sprite.play("morir")

	await sprite.animation_finished

	soltar_recompensa()
	queue_free()

func morir_por_explosion():
	if esta_muerto:
		return

	esta_muerto = true
	esta_atacando = false

	set_physics_process(false)
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)

	sprite.stop()
	sprite.frame = 0
	sprite.play("atacar")

	await sprite.animation_finished

	soltar_recompensa()
	queue_free()

func soltar_recompensa():
	var drop = burbuja_recolectable.instantiate()
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)

func _on_zona_deteccion_body_entered(body):
	if body.name == "Player" or body.is_in_group("jugador"):
		jugador = body

func _on_zona_deteccion_body_exited(body):
	if body == jugador:
		jugador = null
		tiempo_busqueda = 0.0
		velocity = Vector2.ZERO

		var limite_derecho = posicion_inicial.x + distancia_patrullaje
		var limite_izquierdo = posicion_inicial.x - distancia_patrullaje

		if global_position.x >= limite_derecho:
			moviendo_a_derecha = false
		elif global_position.x <= limite_izquierdo:
			moviendo_a_derecha = true

		var direccion_x = 1.0 if moviendo_a_derecha else -1.0

		# Si salió del área ya pegado a pared, arranca patrullaje en sentido contrario
		if hay_pared_enfrente(direccion_x):
			moviendo_a_derecha = !moviendo_a_derecha
			tiempo_cambio_pared = 0.25

#--AUTODESTRUCCION UNA VES QUE EL AJOLTE RECOLECTE LAS LLAVES
func auto_destruccion():
	if esta_muerto:
		return

	esta_muerto = true
	esta_atacando = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)

	sprite.stop()
	sprite.frame = 0

	if sprite and sprite.sprite_frames.has_animation("morir"):
		sprite.play("morir")
		await sprite.animation_finished

	soltar_recompensa()
	queue_free()

func cambiar_color(nuevo_color: Color):
	sprite.modulate = nuevo_color

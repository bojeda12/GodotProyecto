extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var velocidad = 80.0
@export var distancia_ataque = 25.0
@export var salud = 1
@export var distancia_patrullaje = 100.0
var posicion_inicial = Vector2.ZERO
var moviendo_a_derecha = true

@onready var sprite = $AnimatedSprite2D
var burbuja_recolectable = preload("res://scenes/item_burbuja.tscn")

var jugador = null
var esta_muerto = false
var esta_atacando = false

func _ready():
	# Esta línea crea el grupo automáticamente si no existe y añade al pez
	add_to_group("enemigos")
	posicion_inicial = global_position
	sprite.play("nadar")

func _physics_process(_delta):
	if esta_muerto or esta_atacando:
		return

	# 1. LIMPIEZA DE SEGURIDAD
	if jugador != null and not is_instance_valid(jugador):
		jugador = null

	if jugador != null:
		# --- MODO PERSECUCIÓN ---
		var pos_objetivo = jugador.global_position
		var direccion = (pos_objetivo - global_position).normalized()
		velocity = lerp(velocity, direccion * velocidad, 0.05)
		sprite.flip_h = direccion.x < 0
		
		# 2. DETECCIÓN POR COLISIÓN (AQUÍ AGREGAMOS EL ESCUDO)
		var colision = move_and_collide(velocity * _delta)
		if colision:
			var objeto = colision.get_collider()
			
			# Si choca con el campo de fuerza, explota
			if objeto.name == "CampoFuerza":
				lanzar_ataque(true) # Pasamos 'true' para indicar que chocó con el escudo
				return
				
			# Si choca con el jugador directamente
			if is_instance_valid(objeto) and (objeto.name == "Player" or objeto.is_in_group("jugador")):
				lanzar_ataque(false) # 'false' porque no hay escudo
				return

		# 3. DETECCIÓN POR DISTANCIA
		if global_position.distance_to(pos_objetivo) < distancia_ataque:
			lanzar_ataque(false)
		else:
			sprite.play("nadar")
	else:
		ejecutar_patrullaje()

func ejecutar_patrullaje():
	var limite_derecho = posicion_inicial.x + distancia_patrullaje
	var limite_izquierdo = posicion_inicial.x - distancia_patrullaje
	
	if is_on_wall():
		moviendo_a_derecha = !moviendo_a_derecha
		
	if moviendo_a_derecha:
		velocity.x = velocidad * 0.4
		sprite.flip_h = false
		if global_position.x >= limite_derecho:
			moviendo_a_derecha = false
	else:
		velocity.x = -velocidad * 0.4
		sprite.flip_h = true
		if global_position.x <= limite_izquierdo:
			moviendo_a_derecha = true
	
	velocity.y = 0
	move_and_slide()
	sprite.play("nadar")

# --- LÓGICA DE COMBATE ---

func lanzar_ataque(golpeo_escudo: bool = false):
	if not is_instance_valid(jugador) or esta_muerto:
		return
		
	esta_atacando = true
	
	# Impulso más fuerte para asegurar el choque
	var impulso = (jugador.global_position - global_position).normalized()
	velocity = impulso * (velocidad * 3) # Subí el multiplicador a 3
	move_and_slide()
	
	sprite.play("atacar")
	
	# Esperamos un poquito a que el pez "toque" al jugador
	await get_tree().create_timer(0.1).timeout 
	
	if not golpeo_escudo:
		if is_instance_valid(jugador):
			# Aumentamos el rango de 40 a 65 para que sea más efectivo
			if global_position.distance_to(jugador.global_position) < 65.0:
				jugador.recibir_danio(0.50) # <--- AQUÍ CAMBIAS EL DAÑO (0.25 = un cuarto)
				print("¡Impacto! Vida restante: ", jugador.salud)
	
	morir_por_explosion()

func recibir_danio(cantidad):
	if esta_muerto: return
	salud -= cantidad
	if salud <= 0:
		morir()
	else:
		esta_atacando = true 
		sprite.play("herido")
		await sprite.animation_finished
		esta_atacando = false
		sprite.play("nadar")

func morir_por_explosion():
	esta_muerto = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween.finished
	soltar_recompensa()
	queue_free()

func morir():
	esta_muerto = true
	esta_atacando = false
	velocity = Vector2.ZERO 
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	sprite.play("morir")
	await sprite.animation_finished
	soltar_recompensa()
	queue_free()

func soltar_recompensa():
	var drop = burbuja_recolectable.instantiate()
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)
	
func auto_destruccion():
	# 1. Desactivamos las colisiones para que no te hagan daño mientras "explotan"
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 2. Reproducimos la animación "atacar" (que es explotar)
	if sprite and sprite.sprite_frames.has_animation("atacar"):
		sprite.play("atacar")
		
		# 3. Esperamos a que la animación termine automáticamente
		await sprite.animation_finished
	else:
		print("Error: El pez no tiene animación de 'atacar' para explotar")
		
	# 4. Una vez terminada la animación, lo borramos
	queue_free()

# --- SEÑALES ---

func _on_zona_deteccion_body_entered(body):
	if body.name == "Player" or body.is_in_group("jugador"):
		jugador = body

func _on_zona_deteccion_body_exited(body):
	if body == jugador:
		jugador = null
		velocity = Vector2.ZERO
		
#-------------CAMBIO DE COLOR----------

func cambiar_color(nuevo_color: Color):
	# Usamos el nodo 'sprite' que ya tienes definido con @onready
	sprite.modulate = nuevo_color

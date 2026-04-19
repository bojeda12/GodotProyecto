extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var fuerza_impulso: float = 160.0
@export var friccion: float = 0.97
@export var salud: int = 1
@export var escena_basura = preload("res://scenes/3/ManchaBasura.tscn")

# --- VARIABLES DE ESTADO ---
var esta_muerto = false
var direccion_diagonal = Vector2.ZERO
var posicion_inicial: Vector2 = Vector2.ZERO

@onready var sprite = $AnimatedSprite2D
@onready var timer_impulso = $TimerImpulso
@onready var timer_basura = $TimerBasura 

func _ready():
	add_to_group("enemigos")
	posicion_inicial = global_position 
	sprite.play("nadar")
	
	timer_impulso.start()
	timer_basura.start()

func _physics_process(delta):
	if esta_muerto: return
	
	velocity *= friccion
	var colision = move_and_collide(velocity * delta)
	
	if colision:
		velocity = velocity.bounce(colision.get_normal())
		# Lógica adicional: si choca con algo que tiene el método recibir_danio (como el pez)
		var objeto = colision.get_collider()
		if objeto.has_method("recibir_danio") and objeto.is_in_group("jugador"):
			objeto.recibir_danio(0.5)

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

# --- LÓGICA DE MOVIMIENTO (SALTO DIAGONAL) ---
func _on_timer_impulso_timeout():
	if esta_muerto: return
	
	var dir_x = 1 if randf() > 0.5 else -1
	var dir_y = -1 if randf() > 0.3 else 1 
	
	direccion_diagonal = Vector2(dir_x, dir_y).normalized()
	velocity = direccion_diagonal * fuerza_impulso
	
	if sprite.sprite_frames.has_animation("atacar"):
		sprite.play("atacar")
		await get_tree().create_timer(0.6).timeout
		if not esta_muerto: sprite.play("nadar")

# --- LÓGICA DE LA BASURA ---
func _on_timer_basura_timeout():
	if not esta_muerto:
		var nueva_basura = escena_basura.instantiate()
		nueva_basura.global_position = global_position
		get_tree().current_scene.add_child(nueva_basura)
		
		timer_basura.wait_time = randf_range(4.0, 7.0)
		timer_basura.start()

# --- CONTACTO CON EL JUGADOR ---
func _on_zona_deteccion_body_entered(body):
	if esta_muerto: return
	
	if body.is_in_group("jugador"):
		if body.has_method("manchar_pantalla"):
			body.manchar_pantalla()

# --- RECIBIR DAÑO Y MUERTE (IGUAL QUE EL PEZ) ---

# Esta es la función que las burbujas llaman directamente al chocar
func recibir_danio(cantidad):
	if esta_muerto: return
	
	salud -= cantidad
	if salud <= 0:
		morir()
	else:
		# Efecto visual de daño
		var t = create_tween()
		t.tween_property(sprite, "modulate", Color.RED, 0.1)
		t.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func morir():
	if esta_muerto: return
	esta_muerto = true
	
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	
	sprite.stop() 
	sprite.play("morir")
	
	await sprite.animation_finished
	queue_free()

# Mantenemos esta por si tus burbujas usan señales de Area2D
func _on_area_entered(area):
	if esta_muerto: return
	if area.is_in_group("burbujas"):
		recibir_danio(1)
		if area.has_method("explotar"): 
			area.explotar()
		else: 
			area.queue_free()

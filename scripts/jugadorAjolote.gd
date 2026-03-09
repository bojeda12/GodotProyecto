extends CharacterBody2D

@export var velocidad_maxima = 150.0
@export var aceleracion = 0.05
@export var friccion = 0.02
@export var fuerza_salto = -100.0  
var invulnerable = false
@onready var sprite = $AnimatedSprite2D 

# Referencias al HUD
# Usamos la ruta que te dio Godot al arrastrar
@onready var barra_vida = $"../HUD/MarginContainer/VBoxContainer/BarraVida"
@onready var barra_burbujas = $"../HUD/MarginContainer/VBoxContainer/BarraBurbujas"

@export var max_burbujas = 6
var burbujas_actuales = 3 # Cambia a 3 para que empiece con algo de carga
var salud = 3
var muriendo = false

@onready var efecto_disparo = $AnimatedSprite2D2 
var burbuja_scene = preload("res://scenes/burbuja.tscn")

func _ready():
	efecto_disparo.hide()
	# 1. ACTUALIZAR AL INICIO: Para que las barras no aparezcan vacías al empezar
	actualizar_barras()

func _physics_process(_delta):
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	sprite.play("arrriba") 

	if direccion != Vector2.ZERO:
		velocity = lerp(velocity, direccion * velocidad_maxima, 0.04)
		var angulo_meta = direccion.angle() + PI/2
		if velocity.length() < 15:
			rotation = angulo_meta
		else:
			rotation = lerp_angle(rotation, angulo_meta, 0.06)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.015)

	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		disparar_con_efecto()

# --- FUNCIONES DE LA BARRA ---

func actualizar_barras():
	# 2. SINCRONIZACIÓN: Pasamos los valores de las variables a las barras visuales
	if barra_vida:
		barra_vida.value = salud
	if barra_burbujas:
		barra_burbujas.value = burbujas_actuales

func recibir_danio(cantidad):
	if muriendo: return
	salud -= cantidad
	# 3. ACTUALIZAR VIDA: La barra baja inmediatamente al recibir daño
	actualizar_barras()
	
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1) 
	if salud <= 0:
		morir()

func morir():
	if muriendo: return # Doble seguridad
	muriendo = true
	
	print("El ajolote ha muerto")
	# Aquí puedes poner una animación de muerte antes de reiniciar
	await get_tree().create_timer(0.5).timeout 
	
	# Usamos una validación antes de recargar para evitar el error de Nil
	if get_tree() != null:
		get_tree().reload_current_scene()

func disparar_con_efecto():
	# 4. VALIDACIÓN DE MUNICIÓN: Solo dispara si tiene burbujas
	if burbujas_actuales > 0:
		burbujas_actuales -= 1
		actualizar_barras() # La barra de burbujas baja
		
		efecto_disparo.show()
		efecto_disparo.play("EfectoDisparo")
		await efecto_disparo.animation_finished
		efecto_disparo.hide()
		
		var nueva_burbuja = burbuja_scene.instantiate()
		nueva_burbuja.global_position = $Marker2D.global_position
		nueva_burbuja.direccion = Vector2.UP.rotated(rotation)
		nueva_burbuja.rotation = rotation
		get_tree().current_scene.add_child(nueva_burbuja)
	else:
		print("¡No tienes burbujas!")

# Función extra para cuando recojas un objeto de burbuja en el mapa
func recolectar_burbuja():
	if burbujas_actuales < max_burbujas:
		burbujas_actuales += 1
		actualizar_barras() # Esto refresca la UI inmediatamente
		print("Burbuja recolectada: ", burbujas_actuales)

extends CharacterBody2D

@export var velocidad_maxima = 150.0
@export var aceleracion = 0.05
@export var friccion = 0.02
@export var fuerza_salto = -100.0  # Valor negativo para ir hacia arriba

@onready var sprite = $AnimatedSprite2D

func _physics_process(_delta):
	# 1. Obtener dirección de las flechas
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Lógica del Salto Vertical (Espacio)
	if Input.is_action_just_pressed("ui_select"):
		# Forzamos que la velocidad en Y sea hacia arriba
		velocity.y = fuerza_salto
		sprite.play("swim")
	
	# 3. Movimiento normal con las flechas
	if direccion != Vector2.ZERO:
		# Mezclamos la dirección de las flechas con la velocidad actual
		velocity = lerp(velocity, direccion * velocidad_maxima, aceleracion)
		sprite.play("swim")
		
		# Rotación suave hacia donde se mueve
		var angulo_objetivo = velocity.angle()
		rotation = lerp_angle(rotation, angulo_objetivo, 0.1)
	else:
		# Frenado suave
		velocity = lerp(velocity, Vector2.ZERO, friccion)
		sprite.play("reposo")

	# 4. Mantener la orientación correcta (que no nade de cabeza)
	actualizar_orientacion()

	move_and_slide()

func actualizar_orientacion():
	if abs(rotation) > PI / 2:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

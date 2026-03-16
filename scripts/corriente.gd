extends Area2D

@export var fuerza = 800.0  # Ajusta qué tan fuerte empuja
@onready var particulas = $GPUParticles2D
@onready var timer = $Timer

var activa = true

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = 3.0 # Duración de cada fase
	timer.start()

func _on_timer_timeout():
	activa = !activa
	particulas.emitting = activa
	# Si está apagada, cambiamos el color para que el jugador sepa
	modulate.a = 1.0 if activa else 0.2

func _physics_process(delta):
	if activa:
		# Buscamos quién está dentro del área
		for cuerpo in get_overlapping_bodies():
			if cuerpo.is_in_group("jugador") or cuerpo.name == "Player":
				# Empujamos al jugador hacia donde apunte este nodo
				var direccion_empuje = Vector2.RIGHT.rotated(rotation)
				cuerpo.velocity += direccion_empuje * fuerza * delta

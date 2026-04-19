extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var particulas = $OndaParticulas
@onready var zona = $ZonaRealentizacion
@onready var collision_onda = $ZonaRealentizacion/CollisionShape2D
@onready var timer_espera = $TimerEspera

@export var esperar_al_jefe: bool = false
@export var radio_maximo = 110.0 

var expandiendo = false
var activa = false 
var jugador_dentro = false # Para saber si ya le aplicamos la lentitud

func _ready():
	# IMPORTANTE: Copia única del círculo
	collision_onda.shape = collision_onda.shape.duplicate()
	
	if esperar_al_jefe:
		visible = false
		activa = false
		collision_onda.set_deferred("disabled", true)
		anim.stop()
	else:
		activar_anemona()

func activar_anemona():
	activa = true
	visible = true
	collision_onda.set_deferred("disabled", false)
	anim.play("abrir")

func _physics_process(delta):
	if not activa: return

	# Lógica de expansión
	if expandiendo:
		collision_onda.shape.radius += 5 * delta 
		if collision_onda.shape.radius >= radio_maximo:
			expandiendo = false
			collision_onda.shape.radius = 10 

	# --- DETECCIÓN MANUAL (Sustituye a las señales) ---
	var cuerpos = zona.get_overlapping_bodies()
	var hay_jugador = false
	
	for cuerpo in cuerpos:
		if cuerpo.is_in_group("jugador"):
			hay_jugador = true
			break
	
	# Si el jugador entró por primera vez en este frame
	if hay_jugador and not jugador_dentro:
		jugador_dentro = true
		get_tree().call_group("jugador", "aplicar_ralentizacion", true)
	
	# Si el jugador estaba dentro pero ya salió
	elif not hay_jugador and jugador_dentro:
		jugador_dentro = false
		get_tree().call_group("jugador", "aplicar_ralentizacion", false)

func _on_animated_sprite_2d_frame_changed() -> void:
	if anim.frame == 4 and activa:
		expandiendo = true
		collision_onda.shape.radius = 10 
		if particulas: particulas.restart() 

func _on_animated_sprite_2d_animation_finished():
	if activa:
		anim.stop()
		anim.frame = 0 
		timer_espera.start() 

func _on_timer_espera_timeout():
	if activa: anim.play("abrir")

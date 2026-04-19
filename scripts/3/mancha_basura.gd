extends Area2D

# --- CONFIGURACIÓN ---
@export var salud_mancha: int = 1
@export var velocidad_flote: float = 1.5   # Qué tan rápido oscila
@export var amplitud_flote: float = 35.0  # Qué tan lejos se mueve
@export var velocidad_giro: float = 0.4    # Rotación suave

# --- VARIABLES DE ESTADO ---
var tiempo: float = 0.0
var posicion_inicial: Vector2 = Vector2.ZERO
var purificada: bool = false

@onready var sprite = $AnimatedSprite2D # O AnimatedSprite2D según uses

func _ready():
	add_to_group("basura")
	posicion_inicial = global_position
	# Inicio aleatorio para que no todas se muevan igual
	tiempo = randf() * 10.0 
	
	# Avisar al nivel que hay una nueva basura
	notificar_al_nivel(1)

func _physics_process(delta):
	if purificada: return
	
	tiempo += delta * velocidad_flote
	
	# --- MOVIMIENTO FLOTANTE (Seno y Coseno) ---
	var movimiento = Vector2.ZERO
	movimiento.y = sin(tiempo) * amplitud_flote
	movimiento.x = cos(tiempo * 0.8) * (amplitud_flote * 0.4)
	
	global_position = posicion_inicial + movimiento
	
	# --- ROTACIÓN ---
	rotation += sin(tiempo * 0.5) * delta * velocidad_giro

func _on_area_entered(area):
	# 1. Buscamos si el área misma tiene el grupo
	# 2. Si no, buscamos si su padre lo tiene (por si el Area2D es hijo del proyectil)
	var es_burbuja = area.is_in_group("burbujas") or area.get_parent().is_in_group("burbujas")
	
	if es_burbuja and not purificada:
		
		recibir_limpieza()
		
		# Eliminamos la burbuja (ya sea el área o el padre)
		if area.get_parent().is_in_group("burbujas"):
			area.get_parent().queue_free()
		else:
			area.queue_free()

func recibir_limpieza():
	salud_mancha -= 1
	
	# Efecto visual de "golpe" (parpadeo blanco)
	var t = create_tween()
	t.tween_property(self, "modulate", Color(2, 2, 2), 0.1)
	t.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
	
	if salud_mancha <= 0:
		limpiar()

func limpiar():
	if purificada: return
	purificada = true
	
	# Avisar al nivel que esta basura ya se limpió
	notificar_al_nivel(-1)
	
	# Desactivar colisión inmediatamente
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Animación de desaparición (se encoge y se hace transparente)
	var t = create_tween()
	t.set_parallel(true)
	t.tween_property(self, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK)
	t.tween_property(self, "modulate:a", 0, 0.5)
	
	await t.finished
	queue_free()

func notificar_al_nivel(valor: int):
	# Busca la función en la escena principal para actualizar el contador
	var nivel = get_tree().current_scene
	if nivel.has_method("actualizar_conteo_basura"):
		nivel.actualizar_conteo_basura(valor)

extends CharacterBody2D

@export var velocidad: float = 60.0
@export var distancia_patrullaje: float = 100.0
@export var aceleracion: float = 300.0

var posicion_inicial: Vector2
var moviendo_a_derecha: bool = true
@onready var sprite = $AnimatedSprite2D

func _ready():
	# IMPORTANTE: Cambiamos el grupo para que no nos haga daño
	add_to_group("comida")
	# Eliminamos del grupo enemigos por si acaso se copió
	if is_in_group("enemigos"):
		remove_from_group("enemigos")
		
	posicion_inicial = global_position
	sprite.play("nadar")

func _physics_process(delta):
	# Lógica simple de patrullaje
	var limite_derecho = posicion_inicial.x + distancia_patrullaje
	var limite_izquierdo = posicion_inicial.x - distancia_patrullaje

	if moviendo_a_derecha and global_position.x >= limite_derecho:
		moviendo_a_derecha = false
	elif not moviendo_a_derecha and global_position.x <= limite_izquierdo:
		moviendo_a_derecha = true

	# Si choca con una pared, también cambia de dirección
	if is_on_wall():
		moviendo_a_derecha = !moviendo_a_derecha

	var direccion_x = 1.0 if moviendo_a_derecha else -1.0
	velocity.x = move_toward(velocity.x, direccion_x * velocidad, aceleracion * delta)
	
	# Girar el sprite según la dirección
	sprite.flip_h = velocity.x < 0
	
	move_and_slide()

# Esta función la llamará el Ajolote cuando colisione
func ser_comido():
	# Aquí podrías instanciar partículas de burbujas antes de borrar
	queue_free()

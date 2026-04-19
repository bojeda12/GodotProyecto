extends Area2D

@export var velocidad = 400.0
@export var danio = 0.50

@onready var sprite = $AnimatedSprite2D

# DEJA ESTA VARIABLE VACÍA (Vector2.ZERO)
# Así la bala no se moverá hasta que el disparador le diga hacia dónde
var direccion = Vector2.ZERO

func _ready():
	sprite.play("default")
	sprite.modulate = Color(0.2, 1.8, 0.2, 1.0)

func _process(delta):
	if direccion != Vector2.ZERO:
		global_position += direccion * velocidad * delta
		
		# Ajuste para dibujos que miran hacia arriba:
		# Calculamos el ángulo y le sumamos 90 grados (PI/2)
		rotation = direccion.angle() + PI / 2

func _on_body_entered(body):
	# 1. Ignorar disparadores invisibles
	if body.name.contains("Disparador"): 
		return
		
	# 2. NUEVO: Ignorar al jefe (no hace nada y la bala sigue su camino)
	# Esto asume que tu jefe está en el grupo "jefe" o se llama así
	if body.is_in_group("jefe") or body.name.contains("tortuga"):
		return

	# 3. Lógica original: Si es el ajolote, dañarlo
	if body.has_method("recibir_danio"):
		body.recibir_danio(danio)
		queue_free()
	else:
		# Si toca el TileMap (suelo/paredes) u otra cosa, se destruye
		queue_free()

# Conecta esta señal desde el inspector del VisibleOnScreenNotifier2D
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
	
func _on_area_entered(area):
	# Si lo que tocamos está en el grupo de las burbujas
	if area.is_in_group("burbujas"):
		print("¡Burbuja anuló la bala de agua!")
		
		# Eliminamos la burbuja (para que no siga de largo)
		area.queue_free()
		
		# Eliminamos la bala de agua
		queue_free()

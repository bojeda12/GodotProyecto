extends Area2D

var velocidad = 200
var direccion = Vector2.UP

func _physics_process(delta):
	position += direccion * velocidad * delta

# Esta función se activa cuando la burbuja sale de la pantalla
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Elimina la burbuja del juego

# Esta función se activa al tocar un enemigo o pared
func _on_body_entered(body):
	# 1. Ignorar si la burbuja toca al propio Ajolote al salir
	if body.name == "Player":
		return 
	
	# 2. Si toca al Pez (que tiene la función recibir_danio)
	if body.has_method("recibir_danio"):
		print("¡Impacto en el pez!")
		body.recibir_danio(1)
		queue_free() # La burbuja desaparece
	
	# 3. Si toca una pared o el suelo (TileMap)
	elif body is TileMap:
		print("Chocó con pared")
		queue_free()
func destruir_burbuja():
	# Aquí podrías poner una animación de "Pop" antes de borrarla
	queue_free()

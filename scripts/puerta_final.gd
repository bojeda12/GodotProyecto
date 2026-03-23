extends Area2D

@export_file("*.tscn") var escena_jefe = "res://scenes/Enemigo_final1.tscn"
var esta_abierta = false

@onready var cortina = $Transicion/ColorRect # Ajusta la ruta a tu ColorRect

func _ready():
	$AnimatedSprite2D.play("cerrada")
	cortina.modulate.a = 0 # Aseguramos que sea invisible al empezar

func activar_puerta():
	esta_abierta = true
	$AnimatedSprite2D.play("abierta")
	# DESACTIVAR COLISIÓN FÍSICA:
	# Usamos set_deferred por seguridad para no cambiar físicas a mitad de un frame
	if has_node("StaticBody2D/CollisionShape2D"):
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	print("La puerta física se ha deshabilitado, puedes pasar.")

func _on_body_entered(body):
	print("--- INTENTO DE ENTRADA por la puerta ---")
	print("Objeto que entró: ", body.name)
	print("¿Está en grupo jugador?: ", body.is_in_group("jugador"))
	print("¿La puerta está abierta?: ", esta_abierta)
	
	if esta_abierta and body.is_in_group("jugador"):
		print("¡TODO CORRECTO! Iniciando cambio de escena...")
		cambiar_escena_con_fade()
	else:
		print("¡BLOQUEADO! Revisa si falta el grupo 'jugador' o si la variable 'esta_abierta' es false.")

func cambiar_escena_con_fade():
	var tween = create_tween()
	# Hacemos que el ColorRect pase de transparencia 0 a 1 en 1 segundo
	tween.tween_property(cortina, "modulate:a", 1.0, 1.0)
	
	# Esperamos a que el desvanecimiento termine
	await tween.finished
	
	# Cambiamos a la escena del enemigo final
	if escena_jefe:
		get_tree().change_scene_to_file(escena_jefe)
	else:
		print("Error: ¡Olvidaste asignar la escena del jefe en el Inspector!")

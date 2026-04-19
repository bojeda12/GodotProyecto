extends Area2D

# --- VARIABLES CONFIGURABLES DESDE EL INSPECTOR ---
# Aquí arrastras la escena del Jefe o el Splash de Información de cada nivel
@export_file("*.tscn") var escena_destino: String 

var esta_abierta = false

@onready var cortina = $Transicion/ColorRect # Ajusta la ruta a tu ColorRect

func _ready():
	$AnimatedSprite2D.play("cerrada")
	if cortina:
		cortina.modulate.a = 0 # Aseguramos que sea invisible al empezar

func activar_puerta():
	esta_abierta = true
	$AnimatedSprite2D.play("abierta")
	
	# DESACTIVAR COLISIÓN FÍSICA:
	# Esto permite que el ajolote pueda entrar al Area2D una vez abierta
	if has_node("StaticBody2D/CollisionShape2D"):
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	print("Puerta abierta. Destino configurado: ", escena_destino)

func _on_body_entered(body):
	# Verificamos que sea el jugador y que las llaves hayan abierto la puerta
	if esta_abierta and body.is_in_group("jugador"):
		print("¡Entrando al destino!")
		cambiar_escena_con_fade()
	else:
		print("Puerta cerrada o el objeto no es el jugador.")

func cambiar_escena_con_fade():
	if cortina:
		var tween = create_tween()
		# Transición a negro (o el color que tenga tu ColorRect)
		tween.tween_property(cortina, "modulate:a", 1.0, 1.0)
		await tween.finished
	
	# CAMBIO DE ESCENA DINÁMICO
	if escena_destino != "":
		get_tree().change_scene_to_file(escena_destino)
	else:
		print("ERROR: No asignaste una escena en el Inspector (escena_destino)")

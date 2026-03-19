extends "res://scripts/jugadorAjolote.gd" 

var puede_disparar_especial = true
var tiempo_desde_ultima_recarga = 0.0

func _ready():
	# 1. Llamamos al _ready original (para que cargue el HUD y lo demás)
	super._ready() 
	
	# 2. Forzamos el inicio con 6 burbujas solo en esta escena
	burbujas_actuales = 6
	actualizar_barras() # Para que la barra azul se vea llena desde el segundo 1
	print("¡Ajolote listo para el jefe con 6 burbujas!")

func _process(delta):
	# --- RECARGA AUTOMÁTICA DE 2 EN 2 ---
	tiempo_desde_ultima_recarga += delta
	
	if tiempo_desde_ultima_recarga >= 1.0:
		if burbujas_actuales < max_burbujas:
			# Sumamos 2 burbujas cada segundo
			burbujas_actuales = min(burbujas_actuales + 2, max_burbujas)
			actualizar_barras()
		
		tiempo_desde_ultima_recarga = 0.0

func disparar_con_efecto():
	if puede_disparar_especial and burbujas_actuales >= 4:
		puede_disparar_especial = false
		
		# --- LÓGICA ataque para cuando tenga 1 o menos de 1.5 vidas ---
		var cantidad = 12 # Cantidad normal
		var angulo_grados = 90.0 # Ángulo normal
		
		# Si al ajolote le queda poca vida (ejemplo: 1 gota de vida o menos)
		if salud <= 1.5:
			cantidad = 24       # ¡El doble de burbujas!
			angulo_grados = 160.0 # Un abanico casi circular
			print("¡MODO FURIA ACTIVADO!")
			# Efecto visual de furia: un parpadeo rojo rápido
			var t = create_tween()
			t.tween_property(self, "modulate", Color.RED, 0.1)
			t.tween_property(self, "modulate", Color.WHITE, 0.1)

		var angulo_total = deg_to_rad(angulo_grados)
		var angulo_inicial = -angulo_total / 2.0
		var paso = angulo_total / (cantidad - 1)

		efecto_disparo.show()
		efecto_disparo.play("EfectoDisparo")

		for i in range(cantidad):
			var nueva_burbuja = burbuja_scene.instantiate()
			var desviacion = angulo_inicial + (i * paso)
			var angulo_final = rotation + desviacion
			
			nueva_burbuja.global_position = $Marker2D.global_position
			nueva_burbuja.direccion = Vector2.UP.rotated(angulo_final)
			nueva_burbuja.rotation = angulo_final
			
			# Opcional: En modo furia las burbujas podrían ser más grandes
			if salud <= 1.5:
				nueva_burbuja.scale = Vector2(1.5, 1.5)
				
			get_tree().current_scene.add_child(nueva_burbuja)
		
		burbujas_actuales -= 4
		actualizar_barras()
		
		# Cooldown: si estás en furia, ¡recargas más rápido!
		var espera = 1.0 if salud > 1.5 else 0.5
		await get_tree().create_timer(espera).timeout
		
		puede_disparar_especial = true
		efecto_disparo.hide()

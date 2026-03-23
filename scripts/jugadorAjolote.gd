extends CharacterBody2D

@export var velocidad_maxima = 150.0
@export var aceleracion = 0.05
@export var friccion = 0.02
@export var fuerza_salto = -100.0  
var invulnerable = false
@onready var sprite = $AnimatedSprite2D 

# Referencias al HUD
# Usamos la ruta que te dio Godot al arrastrar
@onready var barra_vida = $"../HUD/MarginContainer/VBoxContainer/BarraVida"
@onready var barra_burbujas = $"../HUD/MarginContainer/VBoxContainer/BarraBurbujas"
@onready var etiqueta_llaves = $"../HUD/ContenedorLlaves/HBoxContainer/Label"

@export var max_burbujas = 6
var burbujas_actuales = 3 # Cambia a 3 para que empiece con algo de carga
var salud:float = 3.0
@export var angulo_abanico = 90.0 # El ancho total del disparo en grados
@export var burbujas_por_rafaga = 3 # Cuántas burbujas salen a la vez
#Llaves
var llaves_recolectadas : int = 0
var llaves_necesarias : int = 3

var muriendo = false

@onready var efecto_disparo = $AnimatedSprite2D2 
var burbuja_scene = preload("res://scenes/burbuja.tscn")
var splash_muerte = preload("res://scenes/endSplash.tscn")


func _ready():
	efecto_disparo.hide()
	# 1. ACTUALIZAR AL INICIO: Para que las barras no aparezcan vacías al empezar
	actualizar_barras()

func _physics_process(_delta):
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	sprite.play("arrriba") 

	if direccion != Vector2.ZERO:
		velocity = lerp(velocity, direccion * velocidad_maxima, 0.04)
		var angulo_meta = direccion.angle() + PI/2
		if velocity.length() < 15:
			rotation = angulo_meta
		else:
			rotation = lerp_angle(rotation, angulo_meta, 0.06)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.015)

	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		disparar_con_efecto()
	if Input.is_action_just_pressed("ataque_especial"): # Por defecto es Espacio
		disparar_espiral(10) # Disparamos 12 burbujas para un círculo denso

# --- FUNCIONES DE LA BARRA ---

func actualizar_barras():
	# 2. SINCRONIZACIÓN: Pasamos los valores de las variables a las barras visuales
	if barra_vida:
		barra_vida.value = salud
		print("DEBUG: La salud es ", salud, " y la barra marca ", barra_vida.value)
	if barra_burbujas:
		barra_burbujas.value = burbujas_actuales
		# 3. NUEVO: Actualizamos las llaves recolectadas
	if etiqueta_llaves:
		etiqueta_llaves.text = str(llaves_recolectadas) + " / " + str(llaves_necesarias)

func recibir_danio(cantidad:float):
	if muriendo: return
	salud -= cantidad
	# 3. ACTUALIZAR VIDA: La barra baja inmediatamente al recibir daño
	actualizar_barras()
	
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1) 
	if salud <= 0:
		morir()

func morir():
	if muriendo: return # Doble seguridad
	muriendo = true
	
	print("El ajolote ha muerto")
	# Aquí puedes poner una animación de muerte antes de reiniciar
	await get_tree().create_timer(0.1).timeout 
	
	# Usamos una validación antes de recargar para evitar el error de Nil
	if get_tree() != null:
		var splash = splash_muerte.instantiate()
		get_tree().current_scene.add_child(splash)

func disparar_con_efecto():
	if burbujas_actuales > 0:
		burbujas_actuales -= 1
		actualizar_barras()
		
		efecto_disparo.show()
		efecto_disparo.play("EfectoDisparo")
		await efecto_disparo.animation_finished
		efecto_disparo.hide()
		
		var nueva_burbuja = burbuja_scene.instantiate()
		
		# --- ASIGNAR SONIDO DISPARO NORMAL (ESPACIO) ---
		nueva_burbuja.ruta_sonido = "res://musica/ChorroBurbuja.mp3"
		
		nueva_burbuja.global_position = $Marker2D.global_position
		nueva_burbuja.direccion = Vector2.UP.rotated(rotation)
		nueva_burbuja.rotation = rotation
		get_tree().current_scene.add_child(nueva_burbuja)
	else:
		print("¡No tienes burbujas!")
		
func disparar_circular(cantidad_burbujas: int = 8):
	# Verificamos si tenemos suficientes burbujas para este gran ataque
	if burbujas_actuales >= 2: # Coste de 2 burbujas por ser un ataque fuerte
		burbujas_actuales -= 2
		actualizar_barras()
		
		# El círculo completo tiene 360 grados (o TAU en radianes)
		# Dividimos 360 entre la cantidad de burbujas que queremos
		var paso_angulo = TAU / cantidad_burbujas 
		
		for i in range(cantidad_burbujas):
			var nueva_burbuja = burbuja_scene.instantiate()
			
			# Calculamos la dirección para cada burbuja en el círculo
			var angulo = i * paso_angulo
			var direccion = Vector2.RIGHT.rotated(angulo)
			
			# Configuración de la burbuja
			nueva_burbuja.global_position = global_position
			nueva_burbuja.direccion = direccion
			nueva_burbuja.rotation = angulo + PI/2 # Para que miren hacia afuera
			
			get_tree().current_scene.add_child(nueva_burbuja)
			
		print("¡Ataque Circular!")
	else:
		print("No hay energía suficiente para el ataque circular")
		
func disparar_espiral(cantidad: int = 12):
	if burbujas_actuales >= 3:
		burbujas_actuales -= 3
		actualizar_barras()
		
		var paso_angulo = TAU / cantidad
		
		for i in range(cantidad):
			var nueva_burbuja = burbuja_scene.instantiate()
			
			# --- ASIGNAR SONIDO ESPIRAL (LA X) ---
			nueva_burbuja.ruta_sonido = "res://musica/DisparoEspiralOnda.mp3"
			
			var angulo_inicial = i * paso_angulo
			nueva_burbuja.global_position = global_position
			
			# Configuramos la espiral (aquí la burbuja ya tendrá el sonido cargado)
			if nueva_burbuja.has_method("configurar_espiral"):
				nueva_burbuja.configurar_espiral(angulo_inicial, 200.0, 4.0)
			
			get_tree().current_scene.add_child(nueva_burbuja)
			
		print("¡Ataque Espiral!")
	else:
		print("No hay energía suficiente")

# Función extra para cuando recojas un objeto de burbuja en el mapa
func recolectar_burbuja():
	if burbujas_actuales < max_burbujas:
		burbujas_actuales += 1
		actualizar_barras() # Esto refresca la UI inmediatamente
		print("Burbuja recolectada: ", burbujas_actuales)
func recolectar_llave():
	llaves_recolectadas += 1
	print("¡Llave obtenida! Total: ", llaves_recolectadas)
	
	# Actualizamos el texto del HUD que configuramos antes
	actualizar_barras()
	
	# Opcional: Podrías hacer que el ajolote brille un segundo al agarrarla
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.GOLD, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1).set_delay(0.1)
	
	if llaves_recolectadas >= llaves_necesarias:
		# Detener Spawners
		var lista_spawners = get_tree().get_nodes_in_group("generadores")
		for s in lista_spawners:
			if s.has_method("detener_generacion"):
				s.detener_generacion()
		
		## --- Explosión de enemigos vivos ---
		var enemigos_actuales = get_tree().get_nodes_in_group("enemigos")
		for e in enemigos_actuales:
			## Llamamos a la nueva función de explosión
			if is_instance_valid(e) and e.has_method("auto_destruccion"):
				e.auto_destruccion() # Esto inicia la explosión
		#
		print("¡Misión cumplida! El océano está en paz.")
		
		#Abrir la puerta
		# Buscamos en el grupo "puerta" y llamamos a activar_puerta
		get_tree().call_group("puerta", "activar_puerta")
		print("¡Misión cumplida! La puerta al jefe está abierta.")

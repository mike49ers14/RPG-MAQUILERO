extends CharacterBody2D
## Jugador top-down con movimiento en 8 direcciones.
## Detecta objetos interactuables con un Area2D y los activa con E.

@export var velocidad: float = 110.0

@onready var area_interaccion: Area2D = $AreaInteraccion
@onready var sprite: Sprite2D = $Sprite

var bloqueado: bool = false   # true mientras hay dialogo abierto


func _ready() -> void:
	add_to_group("player")
	Ui.dialogo_iniciado.connect(_on_dialogo_iniciado)
	Ui.dialogo_terminado.connect(_on_dialogo_terminado)


func _exit_tree() -> void:
	if Ui.dialogo_iniciado.is_connected(_on_dialogo_iniciado):
		Ui.dialogo_iniciado.disconnect(_on_dialogo_iniciado)
	if Ui.dialogo_terminado.is_connected(_on_dialogo_terminado):
		Ui.dialogo_terminado.disconnect(_on_dialogo_terminado)


func _on_dialogo_iniciado() -> void:
	bloqueado = true


func _on_dialogo_terminado() -> void:
	bloqueado = false


func _physics_process(_delta: float) -> void:
	if bloqueado:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir := Input.get_vector("mover_izq", "mover_der", "mover_arriba", "mover_abajo")
	velocity = dir * velocidad
	move_and_slide()

	if dir.x > 0.05:
		sprite.flip_h = false
	elif dir.x < -0.05:
		sprite.flip_h = true


func _unhandled_input(event: InputEvent) -> void:
	if bloqueado:
		return
	if event.is_action_pressed("interactuar"):
		_intentar_interactuar()


func _intentar_interactuar() -> void:
	var mas_cerca: Node = null
	var menor_dist := INF
	for a in area_interaccion.get_overlapping_areas():
		if a.has_method("interactuar"):
			var d := global_position.distance_to(a.global_position)
			if d < menor_dist:
				menor_dist = d
				mas_cerca = a
	if mas_cerca != null:
		mas_cerca.interactuar()

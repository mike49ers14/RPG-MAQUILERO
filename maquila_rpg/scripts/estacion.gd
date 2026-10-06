extends Area2D
## Estacion de tarea, estilo Among Us: es un punto en el mapa que, al
## interactuar (E), abre el minijuego de esa tarea como overlay encima
## del mapa. El jugador se queda parado (bloqueado) mientras la tarea
## esta abierta, igual que con un dialogo.

@export var id_tarea: String = ""
@export var nombre_estacion: String = "Estacion"
@export var color: Color = Color("d9a441")
@export var escena_tarea: PackedScene

var _tarea_abierta: Node = null


func _ready() -> void:
	_pintar()


func _pintar() -> void:
	var visual := ColorRect.new()
	visual.color = color
	visual.size = Vector2(34, 34)
	visual.position = Vector2(-17, -17)
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(visual)

	var etiqueta := Label.new()
	etiqueta.name = "Etiqueta"
	etiqueta.position = Vector2(-45, -38)
	etiqueta.size = Vector2(90, 16)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", 10)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(etiqueta)
	_actualizar_etiqueta()

	QuestManager.tarea_completada.connect(func(_id): _actualizar_etiqueta())


func _actualizar_etiqueta() -> void:
	var hecha := QuestManager.esta_completada(id_tarea)
	var marca := " (listo)" if hecha else ""
	$Etiqueta.text = nombre_estacion + marca
	modulate = Color(0.6, 0.6, 0.6) if hecha else Color.WHITE


func interactuar() -> void:
	if escena_tarea == null:
		return
	if QuestManager.esta_completada(id_tarea):
		Ui.mostrar_aviso(nombre_estacion + ": tarea ya completada.")
		return
	if _tarea_abierta != null:
		return

	_tarea_abierta = escena_tarea.instantiate()
	get_tree().current_scene.add_child(_tarea_abierta)
	if _tarea_abierta.has_signal("tarea_terminada"):
		_tarea_abierta.tarea_terminada.connect(_on_tarea_terminada, CONNECT_ONE_SHOT)


func _on_tarea_terminada() -> void:
	_tarea_abierta = null

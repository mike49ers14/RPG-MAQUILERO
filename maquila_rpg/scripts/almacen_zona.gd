extends Area2D
## Zona de entrega del almacen. Al interactuar con la caja cargada aqui,
## se completa la tarea "almacen".

@export var color: Color = Color("4caf82")


func _ready() -> void:
	_pintar()


func _pintar() -> void:
	var v := ColorRect.new()
	v.color = color
	v.color.a = 0.35
	v.size = Vector2(48, 48)
	v.position = Vector2(-24, -24)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)

	var lbl := Label.new()
	lbl.text = "Zona de entrega"
	lbl.position = Vector2(-45, -40)
	lbl.size = Vector2(90, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)


func interactuar() -> void:
	if not GameState.llevando_caja:
		Ui.mostrar_aviso("Primero recoge la caja del almacen.")
		return
	var caja: Node = GameState.caja_actual
	GameState.llevando_caja = false
	GameState.caja_actual = null
	if caja != null:
		caja.queue_free()
	QuestManager.completar("almacen")
	Ui.mostrar_aviso("Entregaste la caja. Tarea de almacen completada.")

extends Area2D
## Caja del almacen. Se "recoge" con E: mientras se carga, sigue al jugador.
## Se suelta al interactuar con la ZonaEntrega (almacen_zona.gd).

@export var color: Color = Color("b58a4a")

var _jugador: Node2D = null


func _ready() -> void:
	_pintar()


func _pintar() -> void:
	var v := ColorRect.new()
	v.color = color
	v.size = Vector2(24, 24)
	v.position = Vector2(-12, -12)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)

	var lbl := Label.new()
	lbl.name = "Etiqueta"
	lbl.text = "Caja"
	lbl.position = Vector2(-30, -34)
	lbl.size = Vector2(60, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)


func _process(_delta: float) -> void:
	if GameState.llevando_caja and GameState.caja_actual == self and _jugador != null:
		global_position = _jugador.global_position + Vector2(0, -26)


func interactuar() -> void:
	if QuestManager.esta_completada("almacen"):
		Ui.mostrar_aviso("Almacen: tarea ya completada.")
		return
	if GameState.llevando_caja:
		return
	_jugador = get_tree().get_first_node_in_group("player")
	GameState.llevando_caja = true
	GameState.caja_actual = self
	$Etiqueta.text = "Cargando..."
	Ui.mostrar_aviso("Recogiste la caja. Llevala a la zona de entrega.")

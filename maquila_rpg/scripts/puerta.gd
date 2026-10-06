extends Area2D
## Puerta / zona de transicion entre escenas.
## Puede exigir que una mision este completada para dejarte pasar.

@export_file("*.tscn") var destino: String = ""
@export var etiqueta: String = "Salida"
@export var color: Color = Color("4caf82")
@export var tam: Vector2 = Vector2(32, 24)

## Requisitos
@export var requiere_mision_completada: String = ""
@export var requiere_contratado: bool = false
@export var mensaje_bloqueado: String = "Todavia no puedes pasar por aqui."
@export var completa_mision: String = ""   # se completa justo antes de cambiar de escena

var _usada: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_pintar()


func _pintar() -> void:
	var visual := ColorRect.new()
	visual.color = color
	visual.size = tam
	visual.position = -tam / 2.0
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(visual)

	var lbl := Label.new()
	lbl.text = etiqueta
	lbl.position = Vector2(-40, -tam.y / 2.0 - 18)
	lbl.size = Vector2(80, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)


func _on_body_entered(body: Node2D) -> void:
	if _usada or not body.is_in_group("player"):
		return

	if requiere_contratado and not GameState.contratado:
		Ui.mostrar_aviso(mensaje_bloqueado)
		return
	if requiere_mision_completada != "" and not QuestManager.esta_completada(requiere_mision_completada):
		Ui.mostrar_aviso(mensaje_bloqueado)
		return
	if destino == "":
		return

	_usada = true
	if completa_mision != "":
		QuestManager.completar(completa_mision)
	GameState.ir_a_escena(destino)

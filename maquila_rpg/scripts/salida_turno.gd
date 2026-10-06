extends Area2D
## Punto de salida de la planta. Solo deja terminar el turno cuando las
## 4 tareas estan completas. Al usarla: paga, avanza el dia, reinicia
## las tareas para el siguiente turno (loop, como las rondas de Among Us).

@export var color: Color = Color("6f7cad")


func _ready() -> void:
	_pintar()


func _pintar() -> void:
	var v := ColorRect.new()
	v.color = color
	v.size = Vector2(40, 30)
	v.position = Vector2(-20, -15)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)

	var lbl := Label.new()
	lbl.text = "Salida / fin de turno"
	lbl.position = Vector2(-50, -34)
	lbl.size = Vector2(100, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)


func interactuar() -> void:
	if not QuestManager.todas_completadas():
		var faltan: int = QuestManager.total_tareas() - QuestManager.contar_completadas()
		Ui.mostrar_aviso("Te faltan %d tareas para poder salir." % faltan)
		return

	QuestManager.reiniciar()
	GameState.guardar()
	GameState.ir_a_escena("res://scenes/casa.tscn")

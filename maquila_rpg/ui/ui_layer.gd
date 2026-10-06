extends CanvasLayer
## AUTOLOAD (escena): HUD + caja de dialogo + avisos.
## Se accede desde cualquier lado como  Ui.mostrar_dialogo(...)

signal dialogo_iniciado
signal dialogo_terminado

@onready var lbl_stats: Label = $Hud/LblStats
@onready var lbl_mision: Label = $Hud/LblMision
@onready var barra_fatiga: ProgressBar = $Hud/BarraFatiga
@onready var lbl_titulo: Label = $Hud/LblTitulo
@onready var lbl_aviso: Label = $Hud/LblAviso

@onready var dialogo: Control = $Dialogo
@onready var lbl_nombre: Label = $Dialogo/Caja/LblNombre
@onready var lbl_texto: Label = $Dialogo/Caja/LblTexto

var _lineas: PackedStringArray = []
var _indice: int = 0
var _frame_inicio: int = -1


func _ready() -> void:
	dialogo.visible = false
	lbl_aviso.visible = false
	GameState.stats_cambiadas.connect(_actualizar_hud)
	QuestManager.tarea_completada.connect(_on_tarea_completada)
	_actualizar_hud()


# ------------------------------------------------------------------- HUD
func _actualizar_hud() -> void:
	lbl_stats.text = "Dia %d   $%d   %s" % [GameState.dia, GameState.dinero, GameState.puesto]
	barra_fatiga.value = GameState.fatiga
	lbl_mision.text = _texto_checklist()


func _texto_checklist() -> String:
	var hechas := QuestManager.contar_completadas()
	var total := QuestManager.total_tareas()
	var texto := "TAREAS  %d/%d\n" % [hechas, total]
	for id in QuestManager.tareas:
		var t: Dictionary = QuestManager.tareas[id]
		var marca := "[x] " if t["hecha"] else "[ ] "
		texto += marca + t["titulo"] + "\n"
	return texto


func _on_tarea_completada(id: String) -> void:
	var titulo: String = QuestManager.tareas[id]["titulo"]
	mostrar_aviso("Tarea completada: " + titulo)
	_actualizar_hud()


func mostrar_titulo(texto: String) -> void:
	lbl_titulo.text = texto
	lbl_titulo.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.5)
	tw.tween_property(lbl_titulo, "modulate:a", 0.0, 0.8)


func mostrar_aviso(texto: String) -> void:
	lbl_aviso.text = texto
	lbl_aviso.visible = true
	lbl_aviso.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(2.0)
	tw.tween_property(lbl_aviso, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func(): lbl_aviso.visible = false)


# --------------------------------------------------------------- DIALOGO
func mostrar_dialogo(nombre: String, lineas: PackedStringArray) -> void:
	if lineas.is_empty():
		return
	_lineas = lineas
	_indice = 0
	_frame_inicio = Engine.get_process_frames()
	lbl_nombre.text = nombre
	lbl_texto.text = _lineas[0]
	dialogo.visible = true
	dialogo_iniciado.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not dialogo.visible:
		return
	if Engine.get_process_frames() == _frame_inicio:
		return
	if event.is_action_pressed("interactuar"):
		_avanzar()
		get_viewport().set_input_as_handled()


func _avanzar() -> void:
	_indice += 1
	if _indice >= _lineas.size():
		dialogo.visible = false
		dialogo_terminado.emit()
	else:
		lbl_texto.text = _lineas[_indice]

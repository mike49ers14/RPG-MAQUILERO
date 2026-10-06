extends Control
## TAREA: Checador de turno.
## Un QTE clasico: aparece una tecla al azar, hay que presionarla antes
## de que se acabe el tiempo. Se hacen RONDAS intentos.

signal tarea_terminada

const RONDAS: int = 5
const VENTANA: float = 0.85

@onready var lbl_tecla: Label = $Panel/LblTecla
@onready var barra: ProgressBar = $Panel/Barra
@onready var lbl_marcador: Label = $Panel/LblMarcador
@onready var lbl_final: Label = $Panel/LblFinal
@onready var btn_cerrar: Button = $Panel/BtnCerrar

var acciones := {
	"mover_arriba": "W",
	"mover_abajo": "S",
	"mover_izq": "A",
	"mover_der": "D",
	"ensamblar": "ESPACIO",
}

var ronda: int = 0
var accion_actual: String = ""
var tiempo_restante: float = 0.0
var aciertos: int = 0
var terminado: bool = false


func _ready() -> void:
	Ui.dialogo_iniciado.emit()
	btn_cerrar.visible = false
	lbl_final.visible = false
	btn_cerrar.pressed.connect(_cerrar)
	_siguiente_ronda()


func _process(delta: float) -> void:
	if terminado or accion_actual == "":
		return
	tiempo_restante -= delta
	barra.value = maxf(tiempo_restante / VENTANA, 0.0) * 100.0
	if tiempo_restante <= 0.0:
		_resolver(false)


func _unhandled_input(event: InputEvent) -> void:
	if terminado or accion_actual == "":
		return
	for accion in acciones:
		if event.is_action_pressed(accion):
			_resolver(accion == accion_actual)
			get_viewport().set_input_as_handled()
			return


func _siguiente_ronda() -> void:
	ronda += 1
	if ronda > RONDAS:
		_terminar()
		return
	accion_actual = acciones.keys()[randi() % acciones.size()]
	lbl_tecla.text = acciones[accion_actual]
	tiempo_restante = VENTANA
	barra.value = 100.0


func _resolver(acierto: bool) -> void:
	if acierto:
		aciertos += 1
		lbl_tecla.modulate = Color("6ee7a0")
	else:
		lbl_tecla.modulate = Color("e4655f")
	accion_actual = ""
	lbl_marcador.text = "Aciertos: %d / %d" % [aciertos, ronda]
	await get_tree().create_timer(0.3).timeout
	lbl_tecla.modulate = Color.WHITE
	_siguiente_ronda()


func _terminar() -> void:
	terminado = true
	lbl_tecla.text = ""
	barra.value = 0
	lbl_final.text = "Checador completado.\nAciertos: %d / %d" % [aciertos, RONDAS]
	lbl_final.visible = true
	btn_cerrar.visible = true
	QuestManager.completar("checador")


func _cerrar() -> void:
	Ui.dialogo_terminado.emit()
	tarea_terminada.emit()
	queue_free()

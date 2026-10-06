extends Control
## TAREA: Control de calidad.
## Pasan piezas una por una, marcadas BUENA o MALA (con ruidito visual de texto).
## Solo debes presionar ESPACIO cuando la pieza sea MALA, dentro de la ventana.
## Se juegan RONDAS piezas; no hay condicion de fallo, siempre se completa,
## pero se muestra tu puntaje al final para que se note el esfuerzo.

signal tarea_terminada

const RONDAS: int = 8
const VENTANA: float = 1.1
const PROB_MALA: float = 0.45

@onready var lbl_pieza: Label = $Panel/LblPieza
@onready var lbl_estado: Label = $Panel/LblEstado
@onready var barra: ProgressBar = $Panel/Barra
@onready var lbl_marcador: Label = $Panel/LblMarcador
@onready var lbl_final: Label = $Panel/LblFinal
@onready var btn_cerrar: Button = $Panel/BtnCerrar

var ronda: int = 0
var es_mala: bool = false
var tiempo_restante: float = 0.0
var esperando_input: bool = false
var aciertos: int = 0
var terminado: bool = false


func _ready() -> void:
	Ui.dialogo_iniciado.emit()
	btn_cerrar.visible = false
	btn_cerrar.pressed.connect(_cerrar)
	_siguiente_ronda()


func _process(delta: float) -> void:
	if terminado or not esperando_input:
		return
	tiempo_restante -= delta
	barra.value = maxf(tiempo_restante / VENTANA, 0.0) * 100.0
	if tiempo_restante <= 0.0:
		_resolver(not es_mala)  # si no presionaste y era mala -> fallaste; si era buena -> acertaste


func _unhandled_input(event: InputEvent) -> void:
	if terminado or not esperando_input:
		return
	if event.is_action_pressed("ensamblar"):
		_resolver(es_mala)  # presionaste: es correcto solo si de verdad era mala
		get_viewport().set_input_as_handled()


func _siguiente_ronda() -> void:
	ronda += 1
	if ronda > RONDAS:
		_terminar()
		return
	es_mala = randf() < PROB_MALA
	lbl_pieza.text = "PIEZA #%d" % ronda
	lbl_estado.text = "Revisando..."
	lbl_estado.modulate = Color.WHITE
	tiempo_restante = VENTANA
	esperando_input = true
	# la pieza se revela un instante despues para que se sienta como inspeccion
	await get_tree().create_timer(0.25).timeout
	if terminado:
		return
	lbl_estado.text = "DEFECTUOSA" if es_mala else "buena"
	lbl_estado.modulate = Color("e4655f") if es_mala else Color("6ee7a0")


func _resolver(acierto: bool) -> void:
	esperando_input = false
	if acierto:
		aciertos += 1
	lbl_marcador.text = "Aciertos: %d / %d" % [aciertos, ronda]
	await get_tree().create_timer(0.35).timeout
	_siguiente_ronda()


func _terminar() -> void:
	terminado = true
	lbl_pieza.text = "TURNO DE CALIDAD TERMINADO"
	lbl_estado.text = ""
	barra.value = 0
	lbl_final.text = "Piezas revisadas: %d\nAciertos: %d / %d" % [RONDAS, aciertos, RONDAS]
	lbl_final.visible = true
	btn_cerrar.visible = true
	QuestManager.completar("calidad")


func _cerrar() -> void:
	Ui.dialogo_terminado.emit()
	tarea_terminada.emit()
	queue_free()

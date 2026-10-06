extends Control

signal tarea_terminada
## MINIJUEGO DE RATE  (el corazon del juego)
##
## Cada pieza que llega a la banda te pide una tecla (W A S D o ESPACIO).
## Si la presionas dentro de la ventana de tiempo -> pieza buena.
## Si fallas o se te va el tiempo -> scrap.
## La fatiga sube con cada pieza y hace la ventana mas corta.
##
## Formula que se muestra al final:
##     RATE = (piezas_buenas * PIEZAS_POR_ACIERTO) / HORAS_TURNO

const DURACION_TURNO: float = 35.0      # segundos reales = 1 tarea completa
const HORAS_TURNO: float = 8.0          # horas simuladas
const PIEZAS_POR_ACIERTO: int = 10      # cada acierto = un lote de 10 piezas
const VENTANA_BASE: float = 0.90        # segundos para responder, sin fatiga
const VENTANA_MIN: float = 0.35
const PAUSA_ENTRE_PIEZAS: float = 0.35
const FATIGA_POR_PIEZA: float = 1.8

@onready var lbl_tiempo: Label = $LblTiempo
@onready var lbl_marcador: Label = $LblMarcador
@onready var lbl_tecla: Label = $Banda/LblTecla
@onready var banda: Panel = $Banda
@onready var barra_ventana: ProgressBar = $BarraVentana
@onready var barra_fatiga: ProgressBar = $BarraFatiga
@onready var panel_resultados: Panel = $PanelResultados
@onready var lbl_resultados: Label = $PanelResultados/LblResultados
@onready var btn_salir: Button = $PanelResultados/BtnSalir

var acciones := {
	"mover_arriba": "W",
	"mover_abajo": "S",
	"mover_izq": "A",
	"mover_der": "D",
	"ensamblar": "ESPACIO",
}

var tiempo_restante: float = DURACION_TURNO
var fatiga_turno: float = 0.0

var buenas: int = 0
var malas: int = 0

var accion_actual: String = ""
var ventana_total: float = 0.0
var ventana_restante: float = 0.0
var en_pausa: float = 0.0
var terminado: bool = false


func _ready() -> void:
	Ui.dialogo_iniciado.emit()
	fatiga_turno = GameState.fatiga
	panel_resultados.visible = false
	btn_salir.pressed.connect(_salir)
	barra_fatiga.max_value = GameState.FATIGA_MAX
	_siguiente_pieza()


func _process(delta: float) -> void:
	if terminado:
		return

	tiempo_restante -= delta
	if tiempo_restante <= 0.0:
		_terminar_turno()
		return

	if en_pausa > 0.0:
		en_pausa -= delta
		if en_pausa <= 0.0:
			_siguiente_pieza()
	elif accion_actual != "":
		ventana_restante -= delta
		barra_ventana.value = (ventana_restante / ventana_total) * 100.0
		if ventana_restante <= 0.0:
			_resolver(false, "SE FUE -> SCRAP")

	_actualizar_hud()


func _unhandled_input(event: InputEvent) -> void:
	if terminado or accion_actual == "" or en_pausa > 0.0:
		return
	for accion in acciones:
		if event.is_action_pressed(accion):
			if accion == accion_actual:
				_resolver(true, "BUENA")
			else:
				_resolver(false, "TECLA MAL -> SCRAP")
			get_viewport().set_input_as_handled()
			return


func _siguiente_pieza() -> void:
	accion_actual = acciones.keys()[randi() % acciones.size()]
	lbl_tecla.text = acciones[accion_actual]
	# A mas fatiga, menos tiempo para reaccionar
	var factor := 1.0 - (fatiga_turno / (GameState.FATIGA_MAX * 2.0))
	ventana_total = maxf(VENTANA_BASE * factor, VENTANA_MIN)
	ventana_restante = ventana_total
	barra_ventana.value = 100.0
	banda.modulate = Color.WHITE


func _resolver(acierto: bool, texto: String) -> void:
	if acierto:
		buenas += 1
		banda.modulate = Color("6ee7a0")
	else:
		malas += 1
		banda.modulate = Color("e4655f")

	lbl_tecla.text = texto
	accion_actual = ""
	en_pausa = PAUSA_ENTRE_PIEZAS
	fatiga_turno = minf(fatiga_turno + FATIGA_POR_PIEZA, GameState.FATIGA_MAX)
	barra_ventana.value = 0.0


func _actualizar_hud() -> void:
	lbl_tiempo.text = "Tiempo de turno: %.1f s" % maxf(tiempo_restante, 0.0)
	lbl_marcador.text = "Buenas: %d    Scrap: %d    Rate parcial: %.1f pzas/h" % [
		buenas, malas, _rate_actual()
	]
	barra_fatiga.value = fatiga_turno


func _rate_actual() -> float:
	var horas_transcurridas: float = maxf(
		(DURACION_TURNO - tiempo_restante) / DURACION_TURNO * HORAS_TURNO, 0.01
	)
	return (buenas * PIEZAS_POR_ACIERTO) / horas_transcurridas


func _terminar_turno() -> void:
	terminado = true
	accion_actual = ""
	lbl_tecla.text = "FIN"

	var rate: float = (buenas * PIEZAS_POR_ACIERTO) / HORAS_TURNO
	var pct_scrap: float = GameState.porcentaje_scrap(buenas, malas)
	var pago: int = int(buenas * PIEZAS_POR_ACIERTO * GameState.TARIFA_POR_PIEZA)

	GameState.registrar_turno(buenas * PIEZAS_POR_ACIERTO, malas * PIEZAS_POR_ACIERTO, rate)
	GameState.fatiga = fatiga_turno

	var cumplio_rate: bool = rate >= GameState.RATE_META
	var cumplio_calidad: bool = pct_scrap < 5.0

	var texto := "REPORTE DE TURNO\n\n"
	texto += "Piezas buenas: %d\n" % (buenas * PIEZAS_POR_ACIERTO)
	texto += "Scrap: %d  (%.1f%%)\n" % [malas * PIEZAS_POR_ACIERTO, pct_scrap]
	texto += "RATE: %.1f pzas/h   (meta: %.0f)\n" % [rate, GameState.RATE_META]
	texto += "Pago del turno: $%d\n\n" % pago
	texto += ("META DE RATE: CUMPLIDA\n" if cumplio_rate else "META DE RATE: NO CUMPLIDA\n")
	texto += ("CALIDAD: APROBADA" if cumplio_calidad else "CALIDAD: RECHAZADA")

	QuestManager.completar("ensamble")
	if cumplio_calidad and GameState.puesto == "Operador de linea":
		GameState.puesto = "Lider de linea"
		GameState.reputacion += 1
	elif not GameState.contratado:
		GameState.contratar()

	lbl_resultados.text = texto
	panel_resultados.visible = true
	btn_salir.grab_focus()


func _salir() -> void:
	GameState.guardar()
	Ui.dialogo_terminado.emit()
	tarea_terminada.emit()
	queue_free()

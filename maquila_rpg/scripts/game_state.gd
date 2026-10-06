extends Node
## AUTOLOAD: estado global del juego.
## Guarda dinero, fatiga, rate, dia y progreso laboral.
## Tambien registra el InputMap por codigo (asi no dependemos del .godot).

signal stats_cambiadas
signal dia_cambiado(dia: int)

const FATIGA_MAX: float = 100.0
const TARIFA_POR_PIEZA: float = 0.35   # pesos que te pagan por pieza buena
const RATE_META: float = 60.0          # piezas/hora que pide el supervisor
const RUTA_GUARDADO: String = "user://partida.cfg"

var dinero: int = 120
var fatiga: float = 0.0
var rate: float = 0.0                  # rate del ultimo turno
var mejor_rate: float = 0.0
var piezas_buenas: int = 0             # acumulado historico
var scrap: int = 0                     # acumulado historico
var dia: int = 1
var contratado: bool = false
var puesto: String = "Desempleado"
var reputacion: int = 0
var turnos_trabajados: int = 0
var llevando_caja: bool = false
var caja_actual: Node = null


func _ready() -> void:
	_configurar_input()


# ---------------------------------------------------------------- INPUT
func _configurar_input() -> void:
	_accion("mover_arriba", [KEY_W, KEY_UP])
	_accion("mover_abajo", [KEY_S, KEY_DOWN])
	_accion("mover_izq", [KEY_A, KEY_LEFT])
	_accion("mover_der", [KEY_D, KEY_RIGHT])
	_accion("interactuar", [KEY_E, KEY_ENTER, KEY_SPACE])
	_accion("ensamblar", [KEY_SPACE])
	_accion("pausa", [KEY_ESCAPE])


func _accion(nombre: String, teclas: Array) -> void:
	if not InputMap.has_action(nombre):
		InputMap.add_action(nombre)
	for t in teclas:
		var ev := InputEventKey.new()
		ev.physical_keycode = t
		InputMap.action_add_event(nombre, ev)


# ---------------------------------------------------------------- STATS
func agregar_dinero(cantidad: int) -> void:
	dinero += cantidad
	stats_cambiadas.emit()


func agregar_fatiga(cantidad: float) -> void:
	fatiga = clampf(fatiga + cantidad, 0.0, FATIGA_MAX)
	stats_cambiadas.emit()


func descansar() -> void:
	fatiga = 0.0
	dia += 1
	dia_cambiado.emit(dia)
	stats_cambiadas.emit()


func contratar(nuevo_puesto: String = "Operador de linea") -> void:
	contratado = true
	puesto = nuevo_puesto
	stats_cambiadas.emit()


func registrar_turno(buenas: int, malas: int, rate_turno: float) -> void:
	piezas_buenas += buenas
	scrap += malas
	rate = rate_turno
	mejor_rate = maxf(mejor_rate, rate_turno)
	turnos_trabajados += 1
	agregar_dinero(int(buenas * TARIFA_POR_PIEZA))
	stats_cambiadas.emit()


func porcentaje_scrap(buenas: int, malas: int) -> float:
	var total := buenas + malas
	if total == 0:
		return 0.0
	return (float(malas) / float(total)) * 100.0


# ---------------------------------------------------------------- ESCENAS
func ir_a_escena(ruta: String) -> void:
	get_tree().change_scene_to_file.call_deferred(ruta)


# ---------------------------------------------------------------- GUARDADO
func guardar() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("jugador", "dinero", dinero)
	cfg.set_value("jugador", "fatiga", fatiga)
	cfg.set_value("jugador", "dia", dia)
	cfg.set_value("jugador", "contratado", contratado)
	cfg.set_value("jugador", "puesto", puesto)
	cfg.set_value("jugador", "mejor_rate", mejor_rate)
	cfg.set_value("tareas", "estado", QuestManager.exportar())
	cfg.save(RUTA_GUARDADO)


func cargar() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(RUTA_GUARDADO) != OK:
		return false
	dinero = cfg.get_value("jugador", "dinero", dinero)
	fatiga = cfg.get_value("jugador", "fatiga", fatiga)
	dia = cfg.get_value("jugador", "dia", dia)
	contratado = cfg.get_value("jugador", "contratado", contratado)
	puesto = cfg.get_value("jugador", "puesto", puesto)
	mejor_rate = cfg.get_value("jugador", "mejor_rate", mejor_rate)
	QuestManager.importar(cfg.get_value("tareas", "estado", {}))
	stats_cambiadas.emit()
	return true

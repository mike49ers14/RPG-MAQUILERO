extends Node
## AUTOLOAD: lista PLANA de tareas (estilo Among Us).
## Ya no hay orden ni bloqueos: las 4 tareas estan disponibles desde el inicio
## y se pueden hacer en cualquier secuencia.

signal tarea_completada(id: String)
signal todas_las_tareas_completadas

var tareas: Dictionary = {
	"ensamble": {"titulo": "Ensamble en linea", "hecha": false},
	"calidad": {"titulo": "Control de calidad", "hecha": false},
	"almacen": {"titulo": "Surtir almacen", "hecha": false},
	"checador": {"titulo": "Checar turno", "hecha": false},
}


func esta_completada(id: String) -> bool:
	return tareas.has(id) and tareas[id]["hecha"]


func esta_activa(id: String) -> bool:
	# Compatibilidad con npc.gd: una tarea "esta activa" si existe y
	# todavia no se ha completado (aqui ya no hay bloqueo por orden).
	return tareas.has(id) and not tareas[id]["hecha"]


func completar(id: String) -> void:
	if not tareas.has(id) or tareas[id]["hecha"]:
		return
	tareas[id]["hecha"] = true
	tarea_completada.emit(id)
	if todas_completadas():
		todas_las_tareas_completadas.emit()


func todas_completadas() -> bool:
	for id in tareas:
		if not tareas[id]["hecha"]:
			return false
	return true


func contar_completadas() -> int:
	var n := 0
	for id in tareas:
		if tareas[id]["hecha"]:
			n += 1
	return n


func total_tareas() -> int:
	return tareas.size()


func reiniciar() -> void:
	for id in tareas:
		tareas[id]["hecha"] = false


func exportar() -> Dictionary:
	var d := {}
	for id in tareas:
		d[id] = tareas[id]["hecha"]
	return d


func importar(d: Dictionary) -> void:
	for id in d:
		if tareas.has(id):
			tareas[id]["hecha"] = d[id]

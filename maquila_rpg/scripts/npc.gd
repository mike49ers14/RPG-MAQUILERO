extends Area2D
## NPC con el que puedes hablar. Puede completar/iniciar misiones
## y mandarte a otra escena al terminar el dialogo.

@export var nombre_npc: String = "NPC"
@export var color: Color = Color("e0a03c")
@export_multiline var lineas: String = "Hola.\nQue tal el turno?"

## Misiones
@export var requiere_mision: String = ""      # solo habla de esto si la mision esta activa
@export var completa_mision: String = ""      # al terminar el dialogo, completa esta mision
@export_multiline var lineas_alternas: String = "Ya no tengo nada para ti."

## Acciones
@export_file("*.tscn") var escena_al_terminar: String = ""
@export var contrata: bool = false            # marca al jugador como contratado
@export var descansa: bool = false            # resetea fatiga y avanza el dia (cama)

var _esperando_fin: bool = false


func _ready() -> void:
	_pintar()


func _pintar() -> void:
	var visual := ColorRect.new()
	visual.color = color
	visual.size = Vector2(20, 28)
	visual.position = Vector2(-10, -20)
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(visual)

	var etiqueta := Label.new()
	etiqueta.text = nombre_npc
	etiqueta.position = Vector2(-30, -40)
	etiqueta.size = Vector2(60, 16)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", 10)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(etiqueta)


func interactuar() -> void:
	var usar_alternas := requiere_mision != "" and not QuestManager.esta_activa(requiere_mision)
	var texto := lineas_alternas if usar_alternas else lineas

	_esperando_fin = not usar_alternas
	Ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)
	Ui.mostrar_dialogo(nombre_npc, texto.split("\n", false))


func _on_dialogo_terminado() -> void:
	if not _esperando_fin:
		return
	_esperando_fin = false

	if contrata:
		GameState.contratar()
	if completa_mision != "":
		QuestManager.completar(completa_mision)
	if descansa:
		GameState.descansar()
		GameState.guardar()
	if escena_al_terminar != "":
		GameState.ir_a_escena(escena_al_terminar)

extends Node2D
## Construye por codigo el piso (con textura repetida) y los 4 muros
## de una sala. El piso usa una textura de 32x32 en modo "tile" para
## que no se vea como un solo color plano.

@export var titulo: String = "Sala"
@export var tam: Vector2 = Vector2(640, 360)
@export var textura_piso: Texture2D = preload("res://assets/sprites/piso_planta.png")
@export var color_muro: Color = Color("161a24")
@export var grosor_muro: float = 12.0


func _ready() -> void:
	_crear_piso()
	_crear_muros()
	Ui.mostrar_titulo(titulo)


func _crear_piso() -> void:
	var piso := TextureRect.new()
	piso.texture = textura_piso
	piso.stretch_mode = TextureRect.STRETCH_TILE
	piso.size = tam
	piso.position = Vector2.ZERO
	piso.z_index = -10
	piso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(piso)
	move_child(piso, 0)


func _crear_muros() -> void:
	var g := grosor_muro
	# rect: posicion + tamanio de cada muro
	var muros := [
		[Vector2(0, 0), Vector2(tam.x, g)],                 # arriba
		[Vector2(0, tam.y - g), Vector2(tam.x, g)],         # abajo
		[Vector2(0, 0), Vector2(g, tam.y)],                 # izquierda
		[Vector2(tam.x - g, 0), Vector2(g, tam.y)],         # derecha
	]
	for m in muros:
		_crear_muro(m[0], m[1])


func _crear_muro(pos: Vector2, medida: Vector2) -> void:
	var cuerpo := StaticBody2D.new()
	cuerpo.position = pos + medida / 2.0
	add_child(cuerpo)

	var forma := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = medida
	forma.shape = rect
	cuerpo.add_child(forma)

	var visual := ColorRect.new()
	visual.color = color_muro
	visual.size = medida
	visual.position = -medida / 2.0
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cuerpo.add_child(visual)

extends TileMapLayer

var shapes = [Piece_I, Piece_J, Piece_L, Piece_O, Piece_S, Piece_T, Piece_Z]
var shapes_full := shapes.duplicate()

#grid variables
const COLS : int = 10
const ROWS : int = 20

#game piece variables
var piece_type
var next_piece_type
var rotation_index : int = 0
var active_piece : Array

#tilemap variables
var tile_id : int = 0
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

#layer variables
var board_layer : int = 0
var active_layer : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start() -> void:
	var shape_class = pick_shape_class()
	var shape = shape_class.new()
	get_parent().add_child(shape)
	print(shape, shape.get_curr_vertices())
	draw_piece(shape.get_curr_vertices(), Vector2i(5,1), Vector2i(1,0))

func pick_shape_class():
	if shapes.is_empty():
		shapes = shapes_full.duplicate()
	shapes.shuffle()
	return shapes.pop_front()

func draw_piece(shape_vertices: Array[Vector2i], pos: Vector2i, atlas: Vector2i) -> void:
	for i in shape_vertices:
		set_cell(pos + i, 0, atlas)

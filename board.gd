extends TileMapLayer

var pieces = [Piece_I, Piece_J, Piece_L, Piece_O, Piece_S, Piece_T, Piece_Z]
var pieces_full := pieces.duplicate()

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

func new_game() -> void:
	var piece_class = pick_piece_class()
	var piece = get_piece(piece_class)
	piece_atlas = Vector2i(pieces_full.find(piece_class),0)
	draw_piece(piece.get_curr_vertices(), Vector2i(5,1), piece_atlas)


func pick_piece_class():
	if pieces.is_empty():
		pieces = pieces_full.duplicate()
	pieces.shuffle()
	return pieces.pop_front()


func get_piece(piece_class) -> PieceBase:
	var piece = piece_class.new()
	get_parent().add_child(piece)
	return piece
	

func draw_piece(shape_vertices: Array[Vector2i], pos: Vector2i, atlas: Vector2i) -> void:
	for i in shape_vertices:
		set_cell(pos + i, 0, atlas)

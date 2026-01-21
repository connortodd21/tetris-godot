extends TileMapLayer

var pieces = [Piece_I, Piece_J, Piece_L, Piece_O, Piece_S, Piece_T, Piece_Z]
var pieces_full := pieces.duplicate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
########################################################
### Piece creation and helpers
########################################################
func pick_piece_class():
	if pieces.is_empty():
		pieces = pieces_full.duplicate()
	pieces.shuffle()
	return pieces.pop_front()
	
func get_piece(piece_class) -> PieceBase:
	var piece = piece_class.new()
	get_parent().add_child(piece)
	return piece
	
	
########################################################
### Active piece drawing
########################################################
func draw_piece(shape_vertices: Array[Vector2i], pos: Vector2i, atlas: Vector2i) -> void:
	for i in shape_vertices:
		set_cell(pos + i, 0, atlas)
		
func erase_piece(active_piece: Array[Vector2i], current_position: Vector2i) -> void:
	for cell in active_piece:
		erase_cell(current_position + cell)

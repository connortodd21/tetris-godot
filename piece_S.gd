extends PieceBase
class_name Piece_S


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	set_vertices(0,   [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)])
	set_vertices(90,  [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)])
	set_vertices(180, [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)])
	set_vertices(270, [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)])



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _to_string() -> String:
	return "PieceS(angle: {0}, angle_to_vertices: {1})".format([angle, angle_to_vertices])

extends Node

class_name PieceBase

var angle_to_vertices := {}
var angle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	angle = 0 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func rotate(curr_angle: int) -> void:
	angle = (curr_angle + 90) % 360

func set_vertices(vertices_angle: int, vertices: Array[Vector2i]) -> void:
	angle_to_vertices[vertices_angle] = vertices

func get_curr_vertices() -> Array[Vector2i]:
	if angle in angle_to_vertices.keys():
		return angle_to_vertices[angle]
	return []

func get_angle():
	return angle

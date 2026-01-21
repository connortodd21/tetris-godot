extends Node2D

var pieces = [Piece_I, Piece_J, Piece_L, Piece_O, Piece_S, Piece_T, Piece_Z]
var pieces_full := pieces.duplicate()

# grid variables
const COLS : int = 10
const ROWS : int = 20

# movement variables
var start_pos := Vector2i(5,1)
var current_pos : Vector2i
var steps : Dictionary[Vector2i, float] = get_default_piece_steps()
const steps_req : float = 50.0 # this needs to match FPS cap. TODO: replace with Timer
var speed : float
const ACCELERATION := 0.25

# game piece variables
var piece_type : PieceBase
var next_piece_type : PieceBase
var rotation_index : int = 0
var active_piece : PieceBase
const next_piece_location = Vector2i(15,6)
var stored_piece : PieceBase
const stored_piece_location = Vector2i(-6,3)

# tilemap variables
var tile_id : int = 0
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i
var stored_piece_atlas : Vector2i
const empty_atlas := Vector2i(-1,-1)

# layer variables
var board_layer : int = 0
var active_layer : int = 1

# score variables
var score := 0
const REWARD := 100

# flag to see if game is running
var game_running := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		if Input.is_action_pressed("ui_down"):
			steps[Vector2i.DOWN] += 10
		if Input.is_action_pressed("ui_left"):
			steps[Vector2i.LEFT] += 10
		if Input.is_action_pressed("ui_right"):
			steps[Vector2i.RIGHT] += 10
		if Input.is_action_just_pressed("ui_up"):
			rotate_piece()
		if Input.is_action_just_pressed("c_key"):
			store_piece()
		
		steps[Vector2i.DOWN] += (speed * (1 + delta))
			
		for direction in steps.keys():
			if steps[direction] > steps_req:
				move_piece(direction)
				steps[direction] = 0

func new_game() -> void:
	score = 0
	speed = 1.0
	steps = get_default_piece_steps()
	clear_board()
	hide_game_over()
	game_running = true
	var piece_class = $active_piece.pick_piece_class()
	piece_type = $active_piece.get_piece(piece_class)
	piece_atlas = Vector2i(pieces_full.find(piece_class),0)
	create_new_piece()
	var next_piece_class = $active_piece.pick_piece_class()
	next_piece_type = $active_piece.get_piece(next_piece_class)
	next_piece_atlas = Vector2i(pieces_full.find(next_piece_class),0)
	show_next_piece()

########################################################
### Collision
########################################################
func is_cell_free(cell: Vector2i) -> bool:
	return $board.is_cell_free(cell)
	
func can_move_piece(direction: Vector2i) -> bool:
	for cell in active_piece.get_curr_vertices():
		if not is_cell_free(cell + current_pos + direction):
			return false
	return true
	
func can_rotate_piece() -> bool:
	var rotation_vertices = active_piece.get_vertices(active_piece.get_next_rotation())
	for cell in rotation_vertices:
		if not is_cell_free(cell + current_pos):
			return false
	return true

########################################################
### Movement
########################################################
func rotate_piece() -> void:
	if can_rotate_piece():
		erase_piece($active_piece)
		rotation_index = (rotation_index + 1) % 4
		active_piece.rotate()
		draw_piece(active_piece, current_pos, piece_atlas, $active_piece)
	
func move_piece(direction: Vector2i) -> void:
	if can_move_piece(direction):
		erase_piece($active_piece)
		current_pos += direction
		draw_piece(active_piece, current_pos, piece_atlas, $active_piece)
	elif direction == Vector2i.DOWN:
		land_piece()
		check_for_completed_rows()
		erase_next_piece()
		piece_type = next_piece_type
		piece_atlas = next_piece_atlas
		create_new_piece()
		generate_next_piece()
		if is_game_over():
			handle_game_over()
			

func get_default_piece_steps() -> Dictionary[Vector2i, float]:
	return {
		Vector2i.LEFT: 0.0,
		Vector2i.DOWN: 0.0,
		Vector2i.RIGHT: 0.0
	}

########################################################
### Piece creation and helpers
########################################################
func store_piece() -> void:
	erase_piece($active_piece)
	if stored_piece != null:
		erase_stored_piece()
		var temp_piece = stored_piece
		var temp_atlas = stored_piece_atlas
		stored_piece = active_piece
		stored_piece_atlas = piece_atlas
		active_piece = temp_piece
		piece_atlas = temp_atlas
	else:
		stored_piece = active_piece
		stored_piece_atlas = piece_atlas
		active_piece = next_piece_type
		piece_atlas = next_piece_atlas
		erase_next_piece()
		generate_next_piece()
		
	stored_piece.angle = 0
	draw_piece(active_piece, current_pos, piece_atlas, $active_piece)
	show_stored_piece()
		

func create_new_piece() -> void:
	# reset piece steps
	steps = get_default_piece_steps()
	current_pos = start_pos
	#piece_type.rotate(rotation_index)
	active_piece = piece_type
	draw_piece(active_piece, current_pos, piece_atlas, $active_piece)
	
func generate_next_piece() -> void:
	var next_piece_class = $active_piece.pick_piece_class()
	next_piece_type = $active_piece.get_piece(next_piece_class)
	next_piece_atlas = Vector2i(pieces_full.find(next_piece_class),0)
	show_next_piece()
	
#########################################################
### Scoring logic
#########################################################
func increment_score(num_completed_rows: int) -> void:
	if num_completed_rows >= 4:
		score += (REWARD * num_completed_rows) + (100 * num_completed_rows)
	else:
		score += REWARD * num_completed_rows
	set_score(score)
	speed += ACCELERATION

	
#########################################################
### Game logic
#########################################################
func handle_game_over() -> void:
	land_piece()
	$HUD.get_node("GameOverLabel").show()
	game_running = false

func is_game_over() -> bool:
	for cell in active_piece.get_curr_vertices():
		if not is_cell_free(cell + current_pos):
			return true
	return false

func is_row_complete(row: int) -> bool:
	for i in range(COLS):
		if is_cell_free(Vector2i(i+1, row)):
			return false
	return true

func check_for_completed_rows() -> void:
	var row = ROWS
	var num_completed_rows = 0
	while row > 0:
		if is_row_complete(row):
			shift_rows(row)
			num_completed_rows += 1
		else:
			row -= 1
	if num_completed_rows > 0:
		increment_score(num_completed_rows)

func shift_rows(row: int) -> void:
	for i in range(row, 1, -1):
		for j in range(COLS):
			var cell = Vector2i(j+1, i)
			var above_cell = Vector2i(j+1, i-1)
			var above_atlas = $board.get_cell_atlas_coords(above_cell)
			if above_atlas == empty_atlas:
				erase_cell($board, cell)
			else:
				set_cell($board, cell, above_atlas)


########################################################
### Board and piece drawing
########################################################
func draw_piece(piece: PieceBase, pos: Vector2i, atlas: Vector2i, tile_layer: TileMapLayer) -> void:
	tile_layer.draw_piece(piece.get_curr_vertices(), pos, atlas)
		
func erase_piece(tile_layer: TileMapLayer) -> void:
	tile_layer.erase_piece(active_piece.get_curr_vertices(), current_pos)
	
func set_cell(tile_layer: TileMapLayer, cell: Vector2i, atlas: Vector2i) -> void:
	tile_layer.set_cell(cell, 0, atlas)
	
func erase_cell(tile_layer: TileMapLayer, cell: Vector2i) -> void:
	tile_layer.erase_cell(cell)
	
func show_next_piece() -> void:
	$active_piece.draw_piece(next_piece_type.get_curr_vertices(), next_piece_location, next_piece_atlas)
	
func erase_next_piece() -> void:
	$active_piece.erase_piece(next_piece_type.get_curr_vertices(), next_piece_location)
	
func show_stored_piece() -> void:
	$active_piece.draw_piece(stored_piece.get_curr_vertices(), stored_piece_location, stored_piece_atlas)
	
func erase_stored_piece() -> void:
	$active_piece.erase_piece(stored_piece.get_curr_vertices(), stored_piece_location)
	
func clear_board() -> void:
	for i in range(ROWS):
		for j in range(COLS):
			erase_cell($board, Vector2i(j+1, i+1))
			erase_cell($active_piece, Vector2i(j+1, i))
	if next_piece_type != null:
		erase_next_piece()
		
	
func land_piece() -> void:
	erase_piece($active_piece)
	draw_piece(active_piece, current_pos, piece_atlas, $board)
	
########################################################
### HUD Interaction
########################################################
func hide_game_over() -> void:
	$HUD.get_node("GameOverLabel").hide()
	
func show_game_over() -> void:
	$HUD.get_node("GameOverLabel").show()
	
func set_score(new_score: int) -> void:
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(new_score)


########################################################
### Signals
########################################################
func _on_hud_game_start() -> void:
	new_game()

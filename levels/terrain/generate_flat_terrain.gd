extends Node3D


@onready var grid_map: GridMap = $GridMap

var chunk_size: int = 32
var chunk_size_bordered: int = chunk_size + 2
var chunk_center: int = chunk_size / 2
var chunk_layer_count: int = 2
var previous_chunk_coord := Vector2i(chunk_center, chunk_center)

var placed_chunks: Array[Vector2i] = []
var chunks_to_solve: Array[Vector2i] = []
var chunks_to_place: Array[Dictionary] = []

var minimum_distance_to_load_chunk: float = 120.0

var is_thread_active: bool = true
var thread: Thread
var semaphore: Semaphore

var noise: FastNoiseLite
var noise_resource: NoiseResource = load("res://noise/cellular_1.tres")

func _ready():
	noise = noise_resource.create_noise()
	
	thread = Thread.new()
	semaphore = Semaphore.new()
	thread.start(handle_chunk_solving)


func _process(delta):
	var player_coords := Vector2i(Player.current_position.x, Player.current_position.z)
	
	var current_chunk_coord = get_nearest_chunk_coord(player_coords)
	if current_chunk_coord != previous_chunk_coord:
		previous_chunk_coord == current_chunk_coord
		semaphore.post()
	
	place_chunk()
	
	DebugMenu.display_value("Player Coords: ", player_coords)
	DebugMenu.display_value("Chunks To Solve: ", chunks_to_solve.size())
	DebugMenu.display_value("Chunks To Place: ", chunks_to_place.size())


func handle_chunk_solving():
	while is_thread_active:
		semaphore.wait()
		var player_coords := Vector2i(Player.current_position.x, Player.current_position.z)
		update_chunks_to_solve(player_coords)
		solve_chunk()


func get_nearest_chunk_coord(player_coords: Vector2i) -> Vector2i:
	var nearest_x: int = (round(player_coords.x / chunk_size) * chunk_size) + chunk_center
	var nearest_y: int = (round(player_coords.y / chunk_size) * chunk_size) + chunk_center
	return Vector2i(nearest_x, nearest_y)


func update_chunks_to_solve(player_coords: Vector2i) -> void:
	var nearby_chunks_coords: Array[Vector2i] = get_chunks_within_minimum_distance_to_load(player_coords)
#	DebugMenu.display_value("Chunks Within Loading: ", nearby_chunks_coords.size())
	for chunk_coord in nearby_chunks_coords:
		if not chunks_to_solve.has(chunk_coord) and not placed_chunks.has(chunk_coord):
			chunks_to_solve.push_back(chunk_coord)


func get_chunks_within_minimum_distance_to_load(player_coords: Vector2i) -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	
	var x = int((player_coords.x - minimum_distance_to_load_chunk) / chunk_size) * chunk_size + chunk_center
	while x < player_coords.x + minimum_distance_to_load_chunk:
		var y = int((player_coords.y - minimum_distance_to_load_chunk) / chunk_size) * chunk_size + chunk_center
		while y < player_coords.y + minimum_distance_to_load_chunk:
			coords.push_back(Vector2i(x, y))
			y += chunk_size
		x += chunk_size
	
	return coords


#func update_chunks_to_solve(center_chunk_coord: Vector2i) -> void:
#	var local_chunks: Array[Vector2i] = get_local_chunks_from(center_chunk_coord)
#	for chunk_coord in local_chunks:
#		var player_position := Vector2(Player.current_position.x, Player.current_position.z)
#		if player_position.distance_to(chunk_coord) < minimum_distance_to_load_chunk:
#			if not chunks_to_solve.has(chunk_coord) and not placed_chunks.has(chunk_coord):
#				chunks_to_solve.push_back(chunk_coord)

#func get_local_chunks_from(middle_chunk: Vector2i) -> Array[Vector2i]:
#	var chunk_array: Array[Vector2i] = []
#	chunk_array.push_back(middle_chunk)
#	chunk_array.push_back(Vector2i(middle_chunk.x + chunk_size, middle_chunk.y))
#	chunk_array.push_back(Vector2i(middle_chunk.x, middle_chunk.y + chunk_size))
#	chunk_array.push_back(Vector2i(middle_chunk.x - chunk_size, middle_chunk.y))
#	chunk_array.push_back(Vector2i(middle_chunk.x, middle_chunk.y - chunk_size))
#	chunk_array.push_back(Vector2i(middle_chunk.x + chunk_size, middle_chunk.y + chunk_size))
#	chunk_array.push_back(Vector2i(middle_chunk.x + chunk_size, middle_chunk.y - chunk_size))
#	chunk_array.push_back(Vector2i(middle_chunk.x - chunk_size, middle_chunk.y + chunk_size))
#	chunk_array.push_back(Vector2i(middle_chunk.x - chunk_size, middle_chunk.y - chunk_size))
#	return chunk_array


func solve_chunk() -> void:
	if chunks_to_solve.size() > 0:
		var new_chunk: Array[Array] = init_empty_chunk()
		apply_noise_to_empty_chunk(chunks_to_solve[0], new_chunk)
		chunks_to_place.push_back({"coord": chunks_to_solve[0], "chunk": new_chunk})
		chunks_to_solve.remove_at(0)


func init_noise_chunk() -> void:
	pass


func init_empty_chunk() -> Array[Array]:
	var new_chunk: Array[Array] = []
	for layer in range(chunk_layer_count):
		new_chunk.push_back([])
		for x in range(chunk_size):
			new_chunk[layer].push_back([])
			for y in range(chunk_size):
				new_chunk[layer][x].push_back(-1)
	return new_chunk


func apply_noise_to_empty_chunk(chunk_coords: Vector2i, empty_chunk: Array[Array]) -> void:
	for layer in chunk_layer_count:
		var noise_level_minimum: float = 1.0 / (chunk_layer_count + 1) * (layer + 1)
		for x in range(0, chunk_size_bordered):
			for y in range(0, chunk_size_bordered):
				var noise_level: float = (noise.get_noise_2d(chunk_coords.x - chunk_center + x, chunk_coords.y - chunk_center + y) + 1) / 2
				if noise_level > noise_level_minimum:
					empty_chunk[layer][x][y] = 0
					empty_chunk[layer][max(0, x-1)][y] = 0
					empty_chunk[layer][x][max(0, y-1)] = 0
					empty_chunk[layer][max(0, x-1)][max(0, y-1)] = 0


func place_chunk() -> void:
	if chunks_to_place.size() > 0:
		placed_chunks.push_back(chunks_to_place[0]["coord"])
		for x in range(0, chunk_size):
			for y in range(0, chunk_size):
				grid_map.set_cell_item(Vector3i(chunks_to_place[0]["coord"].x - chunk_center + x, -1, chunks_to_place[0]["coord"].y - chunk_center + y), 0, 0)
		chunks_to_place.remove_at(0)


func _exit_tree():
	is_thread_active = false
	semaphore.post()
	thread.wait_to_finish()

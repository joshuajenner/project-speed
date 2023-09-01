extends Node3D


@onready var grid_map: GridMap = $GridMap

var noise_resource: NoiseResource = load("res://noise/cellular_1.tres")
var noise: FastNoiseLite = noise_resource.create_noise()

var chunk_size: int = 64
var chunk_center: int = chunk_size / 2
var chunk_size_bordered: int = chunk_size + 2
var chunk_current_coord := Vector2i(chunk_center, chunk_center)
var loaded_chunks: Array[Vector2i] = []
var chunks_to_solve: Array[Vector2i] = []
var minimum_distance_to_load_chunk: float = 640.0

var chunk_layer_count: int = 4
var chunk_data: Array[Array] = []
var chunks_to_place: Array[Dictionary] = []

var thread := Thread.new()
var semaphore := Semaphore.new()
var is_thread_active: bool = true

func _ready():
	thread.start(handle_chunk_loading)


func _physics_process(delta):
	update_current_chunk_position()
	check_for_chunks_to_load()
	load_chunks()
	place_chunks()


func handle_chunk_loading():
	while is_thread_active:
#		update_current_chunk_position()
#		check_for_chunks_to_load()
#		load_chunks()
		semaphore.wait()


func update_current_chunk_position() -> void:
	var player_2d_position := Vector2(Player.current_position.x, Player.current_position.z)
	chunk_current_coord = get_nearest_chunk_coord_to(player_2d_position)

func get_nearest_chunk_coord_to(check_position: Vector2) -> Vector2i:
	var nearest_x: int = (round(check_position.x / chunk_size) * chunk_size) + chunk_center
	var nearest_y: int = (round(check_position.y / chunk_size) * chunk_size) + chunk_center
	return Vector2i(nearest_x, nearest_y)


func check_for_chunks_to_load() -> void:
	var local_chunks: Array[Vector2i] = get_local_chunks_from(chunk_current_coord)
	for chunk_coord in local_chunks:
		var player_position := Vector2(Player.current_position.x, Player.current_position.z)
		if player_position.distance_to(chunk_coord) < minimum_distance_to_load_chunk:
			if not chunks_to_solve.has(chunk_coord) and not loaded_chunks.has(chunk_coord):
				chunks_to_solve.push_back(chunk_coord)
				DebugMenu.display_value("Chunks To Solve: ", chunks_to_solve.size())

func get_local_chunks_from(middle_chunk: Vector2i) -> Array[Vector2i]:
	var chunk_array: Array[Vector2i] = []
	chunk_array.push_back(middle_chunk)
	chunk_array.push_back(Vector2i(middle_chunk.x + chunk_size, middle_chunk.y))
	chunk_array.push_back(Vector2i(middle_chunk.x, middle_chunk.y + chunk_size))
	chunk_array.push_back(Vector2i(middle_chunk.x - chunk_size, middle_chunk.y))
	chunk_array.push_back(Vector2i(middle_chunk.x, middle_chunk.y - chunk_size))
	chunk_array.push_back(Vector2i(middle_chunk.x + chunk_size, middle_chunk.y + chunk_size))
	chunk_array.push_back(Vector2i(middle_chunk.x + chunk_size, middle_chunk.y - chunk_size))
	chunk_array.push_back(Vector2i(middle_chunk.x - chunk_size, middle_chunk.y + chunk_size))
	chunk_array.push_back(Vector2i(middle_chunk.x - chunk_size, middle_chunk.y - chunk_size))
	return chunk_array


func load_chunks() -> void:
	if chunks_to_solve.size() > 0:
		if not loaded_chunks.has(chunks_to_solve[0]):
			init_cells_arrays()
			generate_tilemap(noise, chunks_to_solve[0])
			solve_tilemap()
			chunks_to_place.push_back({"coord": chunks_to_solve[0], "chunk": chunk_data})
			DebugMenu.display_value("Chunks To Place: ", chunks_to_place.size())
			chunks_to_solve.remove_at(0)
			DebugMenu.display_value("Chunks To Solve: ", chunks_to_solve.size())


func place_chunks() -> void:
	if chunks_to_place.size() > 0:
		map_chunk_to_gridmap(chunks_to_place[0])
		chunks_to_place.remove_at(0)
		DebugMenu.display_value("Chunks To Place: ", chunks_to_place.size())
		semaphore.post()


func init_cells_arrays() -> void:
	chunk_data.clear()
	for l in range(chunk_layer_count):
		chunk_data.push_back([])
		for x in range(chunk_size_bordered):
			chunk_data[l].push_back([])
			for y in range(chunk_size_bordered):
				chunk_data[l][x].push_back(-1)


func _on_noise_generator_noise_generated(new_noise: FastNoiseLite):
	noise = new_noise
	loaded_chunks = []
	grid_map.clear()
	init_cells_arrays()
	generate_tilemap(noise, Vector2i(chunk_center, chunk_center))
	solve_tilemap()
#	map_chunk_to_gridmap(Vector2i(chunk_center, chunk_center))


func generate_tilemap(noise: FastNoiseLite, chunk_coords: Vector2i) -> void:
	for layer in chunk_layer_count:
		var noise_level_minimum: float = 1.0 / (chunk_layer_count + 1) * (layer + 1)
		for x in range(0, chunk_size_bordered):
			for y in range(0, chunk_size_bordered):
				var noise_level: float = (noise.get_noise_2d(chunk_coords.x - chunk_center + x, chunk_coords.y - chunk_center + y) + 1) / 2
				if noise_level > noise_level_minimum:
					chunk_data[layer][x][y] = 0
					chunk_data[layer][max(0, x-1)][y] = 0
					chunk_data[layer][x][max(0, y-1)] = 0
					chunk_data[layer][max(0, x-1)][max(0, y-1)] = 0
#	print("Cells Picked")


func solve_tilemap() -> void:
	for l in range(chunk_layer_count):
		for x in range(0, chunk_size_bordered):
			for y in range(0, chunk_size_bordered):
				if chunk_data[l][x][y] >= 0:
					var cell_index: int = get_cell_index_from_surrounding_cells(chunk_data, l, x, y)
					chunk_data[l][x][y] = cell_index
#	print("Cells Orientated")


func get_cell_index_from_surrounding_cells(cell_map: Array, layer: int, cell_x: int, cell_y: int) -> int:
	var index: int = 0
	if cell_map[layer][cell_x][cell_y - 1] >= 0:
		index += 1
	if cell_map[layer][min(chunk_size_bordered-1, cell_x + 1)][cell_y] >= 0:
		index += 2
	if cell_map[layer][cell_x][min(chunk_size_bordered-1, cell_y + 1)] >= 0:
		index += 4
	if cell_map[layer][cell_x - 1][cell_y] >= 0:
		index += 8
	
	if index == 15:
		index = solve_surrounded_cell(cell_map, layer, cell_x, cell_y)
	return index

func solve_surrounded_cell(cell_map: Array, layer: int, cell_x: int, cell_y: int) -> int:
	var index: int = 0
	if cell_map[layer][cell_x - 1][cell_y - 1] < 0:
		index += 8
	if cell_map[layer][min(chunk_size_bordered-1, cell_x + 1)][cell_y - 1] < 0:
		index += 1
	if cell_map[layer][cell_x - 1][min(chunk_size_bordered-1, cell_y + 1)] < 0:
		index += 4
	if cell_map[layer][min(chunk_size_bordered-1, cell_x + 1)][min(chunk_size_bordered-1, cell_y + 1)] < 0:
		index += 2
	return index


func map_chunk_to_gridmap(new_chunk: Dictionary) -> void:
	for l in range(chunk_layer_count):
		for x in range(0, chunk_size):
			for y in range(0, chunk_size):
				if l == 0:
					grid_map.set_cell_item(Vector3i(new_chunk["coord"].x - chunk_center + x, -1, new_chunk["coord"].y - chunk_center + y), 0, 0)
				grid_map.set_cell_item(Vector3i(new_chunk["coord"].x - chunk_center + x, l, new_chunk["coord"].y - chunk_center + y), new_chunk["chunk"][l][x+1][y+1], 0)
	loaded_chunks.push_back(new_chunk["coord"])
	DebugMenu.display_value("Loaded Chunks: ", loaded_chunks.size())


func _exit_tree():
	is_thread_active = false
	semaphore.post()
	thread.wait_to_finish()

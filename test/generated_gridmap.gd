extends Node3D


@onready var tile_map: TileMap = %TileMap
@onready var grid_map: GridMap = $GridMap

var noise_resource: NoiseResource = load("res://noise/cellular_1.tres")
var noise: FastNoiseLite = noise_resource.create_noise()

var chunk_size: int = 128
var chunk_center: int = chunk_size / 2
var chunk_size_bordered: int = chunk_size + 2
var chunk_current_coord := Vector2i(chunk_center, chunk_center)
var loaded_chunks: Array[Vector2i] = []
var chunks_to_load: Array[Vector2i] = []
var minimum_distance_to_load_chunk: float = 128.0


var chunk_layer_count: int = 4
var chunk_data: Array[Array] = []


func _ready():
	pass


func _physics_process(delta):
	update_current_chunk_position()
	check_for_chunks_to_load()
	load_chunks()


func update_current_chunk_position() -> void:
	var player_2d_position := Vector2(Player.current_position.x, Player.current_position.z)
	chunk_current_coord = get_nearest_chunk_coord_to(player_2d_position)


func check_for_chunks_to_load() -> void:
	var local_chunks: Array[Vector2i] = get_local_chunks_from(chunk_current_coord)
	for chunk_coord in local_chunks:
		var player_position := Vector2(Player.current_position.x, Player.current_position.z)
		if player_position.distance_to(chunk_coord) < minimum_distance_to_load_chunk:
			if not chunks_to_load.has(chunk_coord) and not loaded_chunks.has(chunk_coord):
				chunks_to_load.push_back(chunk_coord)


func get_nearest_chunk_coord_to(check_position: Vector2) -> Vector2i:
	var nearest_x: int = (round(check_position.x / chunk_size) * chunk_size) + chunk_center
	var nearest_y: int = (round(check_position.y / chunk_size) * chunk_size) + chunk_center
	return Vector2i(nearest_x, nearest_y)


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
	if chunks_to_load.size() > 0:
		if not loaded_chunks.has(chunks_to_load[0]):
			init_cells_arrays()
			generate_tilemap(noise, chunks_to_load[0])
			solve_tilemap()
			map_tilemap_to_gridmap(chunks_to_load[0])
			chunks_to_load.remove_at(0)

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
	map_tilemap_to_gridmap(Vector2i(chunk_center, chunk_center))


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
#			if noise_level > 0.60:
#				mapped_cells_1[x][y] = 0
#				mapped_cells_1[max(0, x-1)][y] = 0
#				mapped_cells_1[x][max(0, y-1)] = 0
#				mapped_cells_1[max(0, x-1)][max(0, y-1)] = 0
#			elif noise_level > 0.40:
#				mapped_cells_0[x][y] = 0
#				mapped_cells_0[max(0, x-1)][y] = 0
#				mapped_cells_0[x][max(0, y-1)] = 0
#				mapped_cells_0[max(0, x-1)][max(0, y-1)] = 0
	print("Cells Picked")


func solve_tilemap() -> void:
	for l in range(chunk_layer_count):
		for x in range(0, chunk_size_bordered):
			for y in range(0, chunk_size_bordered):
				if chunk_data[l][x][y] >= 0:
					var cell_index: int = get_cell_index_from_surrounding_cells(chunk_data, l, x, y)
					chunk_data[l][x][y] = cell_index
	print("Cells Orientated")


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


func map_tilemap_to_gridmap(chunk_coord: Vector2i) -> void:
	for l in range(chunk_layer_count):
		for x in range(0, chunk_size):
			for y in range(0, chunk_size):
				if l == 0:
					grid_map.set_cell_item(Vector3i(chunk_coord.x - chunk_center + x, -1, chunk_coord.y - chunk_center + y), 0, 0)
				grid_map.set_cell_item(Vector3i(chunk_coord.x - chunk_center + x, l, chunk_coord.y - chunk_center + y), chunk_data[l][x+1][y+1], 0)
	loaded_chunks.push_back(chunk_coord)

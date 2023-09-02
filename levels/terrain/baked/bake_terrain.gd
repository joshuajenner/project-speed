extends Node3D

var map_size: int = 300
var map_layer_count: int = 2

var noise: FastNoiseLite
var noise_resource: NoiseResource = load("res://noise/cellular_1.tres")

var custom_cell_size = Vector3(0.99, 0.5, 0.99)
var custom_mesh_library = preload("res://test/mesh_library_gridmap.tres")


func _ready():
	noise = noise_resource.create_noise()
	
	var grid_map := GridMap.new()
	grid_map.cell_size = custom_cell_size
	grid_map.mesh_library = custom_mesh_library
	
	var map: Array[Array] = init_noise_map()
	
	for l in range(map_layer_count):
		for x in range(-map_size, map_size):
			for y in range(-map_size, map_size):
				if map[l][x+map_size][y+map_size] >= 0:
					var cell_index: int = get_cell_index_from_surrounding_cells(map, l, x+map_size, y+map_size)
					map[l][x+map_size][y+map_size] = cell_index
	
	for l in map_layer_count:
		print(l)
		for x in range(-map_size, map_size):
			for y in range(-map_size, map_size):
				if l == 0:
					grid_map.set_cell_item(Vector3i(x, -1, y), 0, 0)
				grid_map.set_cell_item(Vector3i(x, l, y), map[l][x+map_size][y+map_size], 0)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(grid_map)
	ResourceSaver.save(packed_scene, "res://levels/terrain/baked/map_0.tscn")
	print("Saved")



func init_noise_map() -> Array[Array]:
	var new_chunk: Array[Array] = []
	for layer in map_layer_count:
		var noise_level_minimum: float = 1.0 / (map_layer_count + 1) * (layer + 1)
		new_chunk.push_back([])
		for x in range(0, map_size*2):
			new_chunk[layer].push_back([])
			for y in range(0, map_size*2):
				var noise_level: float = (noise.get_noise_2d(x - map_size, y - map_size) + 1) / 2
				if noise_level > noise_level_minimum:
					new_chunk[layer][x].push_back(0)
					new_chunk[layer][max(0, x-1)][y] = 0
					new_chunk[layer][x][max(0, y-1)] = 0
					new_chunk[layer][max(0, x-1)][max(0, y-1)] = 0
				else:
					new_chunk[layer][x].push_back(-1)
	return new_chunk

func get_cell_index_from_surrounding_cells(cell_map: Array, layer: int, cell_x: int, cell_y: int) -> int:
	var index: int = 0
	if cell_map[layer][cell_x][cell_y - 1] >= 0:
		index += 1
	if cell_map[layer][min(map_size*2-1, cell_x + 1)][cell_y] >= 0:
		index += 2
	if cell_map[layer][cell_x][min(map_size*2-1, cell_y + 1)] >= 0:
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
	if cell_map[layer][min(map_size*2-1, cell_x + 1)][cell_y - 1] < 0:
		index += 1
	if cell_map[layer][cell_x - 1][min(map_size*2-1, cell_y + 1)] < 0:
		index += 4
	if cell_map[layer][min(map_size*2-1, cell_x + 1)][min(map_size*2-1, cell_y + 1)] < 0:
		index += 2
	return index

extends Node3D


@onready var tile_map: TileMap = %TileMap
@onready var grid_map: GridMap = $GridMap

var map_size: int = 256
var mapped_cells_0: Array[Array] = []
var mapped_cells_1: Array[Array] = []


func _ready():
	init_cells_arrays()
	print(Player.current_position)


func init_cells_arrays() -> void:
	mapped_cells_0.clear()
	mapped_cells_1.clear()
	for x in range(map_size):
		mapped_cells_0.push_back([])
		mapped_cells_1.push_back([])
		for y in range(map_size):
			mapped_cells_0[x].push_back(-1)
			mapped_cells_1[x].push_back(-1)


func _on_noise_generator_noise_generated(noise: FastNoiseLite):
	init_cells_arrays()
	generate_tilemap(noise)
	solve_tilemap()
	map_tilemap_to_gridmap()


func generate_tilemap(noise: FastNoiseLite) -> void:
	for x in range(0, map_size):
		for y in range(0, map_size):
			var noise_level = (noise.get_noise_2d(x, y) + 1) / 2
			if noise_level > 0.60:
				mapped_cells_0[x][y] = 0
				mapped_cells_0[max(0, x-1)][y] = 0
				mapped_cells_0[x][max(0, y-1)] = 0
				mapped_cells_0[max(0, x-1)][max(0, y-1)] = 0
			elif noise_level > 0.40:
				mapped_cells_1[x][y] = 0
				mapped_cells_1[max(0, x-1)][y] = 0
				mapped_cells_1[x][max(0, y-1)] = 0
				mapped_cells_1[max(0, x-1)][max(0, y-1)] = 0
	print("Cells Picked")


func solve_tilemap() -> void:
	for x in range(0, map_size):
		for y in range(0, map_size):
			if mapped_cells_0[x][y] >= 0:
				var cell_index: int = get_cell_index_from_surrounding_cells(mapped_cells_0, x, y)
				mapped_cells_0[x][y] = cell_index
			if mapped_cells_1[x][y] >= 0:
				var cell_index: int = get_cell_index_from_surrounding_cells(mapped_cells_1, x, y)
				mapped_cells_1[x][y] = cell_index
	print("Cells Orientated")


func get_cell_index_from_surrounding_cells(cell_map: Array, cell_x: int, cell_y: int) -> int:
	var index: int = 0
	if cell_map[cell_x][cell_y - 1] >= 0:
		index += 1
	if cell_map[min(map_size-1, cell_x + 1)][cell_y] >= 0:
		index += 2
	if cell_map[cell_x][min(map_size-1, cell_y + 1)] >= 0:
		index += 4
	if cell_map[cell_x - 1][cell_y] >= 0:
		index += 8
		
	if index == 15:
		index = solve_surrounded_cell(cell_map, cell_x, cell_y)
	return index


func solve_surrounded_cell(cell_map: Array, cell_x: int, cell_y: int) -> int:
	var index: int = 0
	if cell_map[cell_x - 1][cell_y - 1] < 0:
		index += 8
	if cell_map[min(map_size-1, cell_x + 1)][cell_y - 1] < 0:
		index += 1
	if cell_map[cell_x - 1][min(map_size-1, cell_y + 1)] < 0:
		index += 4
	if cell_map[min(map_size-1, cell_x + 1)][min(map_size-1, cell_y + 1)] < 0:
		index += 2
	return index


func map_tilemap_to_gridmap() -> void:
	grid_map.clear()
	for x in range(0, map_size):
		for y in range(0, map_size):
			grid_map.set_cell_item(Vector3i(x, 0, y), 0, 0)
			grid_map.set_cell_item(Vector3i(x, 1, y), mapped_cells_0[x][y], 0)
			grid_map.set_cell_item(Vector3i(x, 2, y), mapped_cells_1[x][y], 0)

extends Node3D


@onready var tile_map: TileMap = %TileMap
@onready var grid_map: GridMap = $GridMap


var map_size: int = 256
var mapped_cells_0: Array[Array] = []
var mapped_cells_1: Array[Array] = []


func _ready():
	init_cells_arrays()
#	var myQuaternion = Quaternion(Vector3(0, 1, 0), deg_to_rad(-90))
#	var cell_item_orientation = grid_map.get_orthogonal_index_from_basis(Basis(myQuaternion))
#	print(cell_item_orientation)

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
#	Yellow NorthEast corner = 1
#	Yellow SouthEast corner = 2
#	Yellow Sout-West corner = 4
#	Yellow NorthWest corner = 8
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
	if cell_map[cell_x - 1][cell_y - 1] >= 0:
		index += 8
	if cell_map[min(map_size-1, cell_x + 1)][cell_y - 1] >= 0:
		index += 1
	if cell_map[cell_x - 1][min(map_size-1, cell_y + 1)] >= 0:
		index += 4
	if cell_map[min(map_size-1, cell_x + 1)][min(map_size-1, cell_y + 1)] >= 0:
		index += 2
	return index






#func generate_tilemap(noise: FastNoiseLite):
#	mapped_cells_0 = []
#	mapped_cells_1 = []
#	tile_map.clear()
#	for x in range(-map_size, map_size):
#		for y in range(-map_size, map_size):
#			var noise_level = (noise.get_noise_2d(x, y) + 1) / 2
#			if noise_level > 0.60:
#				mapped_cells_0.append(Vector2i(x, y))
#				mapped_cells_0.append(Vector2i(x-1, y))
#				mapped_cells_0.append(Vector2i(x, y-1))
#				mapped_cells_0.append(Vector2i(x-1, y-1))
#			elif noise_level > 0.40:
#				mapped_cells_1.append(Vector2i(x, y))
#				mapped_cells_1.append(Vector2i(x-1, y))
#				mapped_cells_1.append(Vector2i(x, y-1))
#				mapped_cells_1.append(Vector2i(x-1, y-1))
				
#	tile_map.set_cells_terrain_connect(0, mapped_cells_0, 0, 0)
#	tile_map.set_cells_terrain_connect(1, mapped_cells_1, 0, 1)

func map_tilemap_to_gridmap() -> void:
	grid_map.clear()
	for x in range(0, map_size):
		for y in range(0, map_size):
			grid_map.set_cell_item(Vector3i(x, 0, y), 0, 0)
			grid_map.set_cell_item(Vector3i(x, 1, y), mapped_cells_0[x][y], 0)
			grid_map.set_cell_item(Vector3i(x, 2, y), mapped_cells_1[x][y], 0)

func map_tilemap_to_gridmap_old() -> void:
	grid_map.clear()
	for x in range(-map_size, map_size):
		for y in range(-map_size, map_size):
			grid_map.set_cell_item(Vector3i(x, 0, y), 0, 0)
			# First Layer
			var cell_atlas_coords: Vector2i = tile_map.get_cell_atlas_coords(1, Vector2i(x,y))
			if cell_atlas_coords != Vector2i(-1, -1):
				var item_index = get_item_from_cell_atlas(cell_atlas_coords)
				var orientation_index = get_orientation_from_cell_atlas(cell_atlas_coords)
				grid_map.set_cell_item(Vector3i(x, 1, y), item_index, orientation_index)
			
			# Second Layer
			cell_atlas_coords = tile_map.get_cell_atlas_coords(0, Vector2i(x,y))
			if cell_atlas_coords != Vector2i(-1, -1):
				var item_index = get_item_from_cell_atlas(cell_atlas_coords)
				var orientation_index = get_orientation_from_cell_atlas(cell_atlas_coords)
				grid_map.set_cell_item(Vector3i(x, 2, y), item_index, orientation_index)



func get_item_from_cell_atlas(coords: Vector2i) -> int:
	if coords.x == 0:
		return 0
	if coords.x >= 1 and coords.x <= 4:
		return 1
	if coords.x >= 5 and coords.x <= 8:
		return 2
	if coords.x >= 9 and coords.x <= 12:
		return 3
	
	return 0


func get_orientation_from_cell_atlas(coords: Vector2i) -> int:
	# 180 = 10
	# 90 = 16
	# -90 = 22
	# 0 = 0
	var x: int = coords.x
	if x == 0 or x == 3 or x == 7 or x == 12:
		return 0
	if x == 1 or x == 6 or x == 10:
		return 10
	if x == 4 or x == 5 or x == 9:
		return 22
	if x == 2 or x == 8 or x == 11:
		return 16
		
	return 0

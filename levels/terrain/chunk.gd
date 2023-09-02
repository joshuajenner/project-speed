extends GridMap
class_name Chunk

@onready var chunk = $"."

var noise: FastNoiseLite
var coord: Vector2i
var size: int
var size_bordered: int
var center: int
var layer_count: int


func _init(_noise, _coord, _size, _layers):
	self.noise = _noise
	self.coord = _coord
	self.size = _size
	self.size_bordered = _size+2
	self.center = _size/2
	self.layer_count = _layers


func _ready():
	generate_chunk()


func generate_chunk() -> void:
	var new_chunk: Array[Array] = init_noise_chunk(coord)
	for l in range(layer_count):
			for x in range(0, size_bordered):
				for y in range(0, size_bordered):
					if new_chunk[l][x][y] >= 0:
						var cell_index: int = get_cell_index_from_surrounding_cells(new_chunk, l, x, y)
						new_chunk[l][x][y] = cell_index
	set_gridmap(new_chunk)


func set_gridmap(new_chunk: Array[Array]) -> void:
	for l in layer_count:
			for x in range(0, size):
				for y in range(0, size):
					if l == 0:
						chunk.set_cell_item(Vector3i(x, -1, y), 0, 0)
					chunk.set_cell_item(Vector3i(x, l, y), new_chunk[l][x+1][y+1], 0)



func get_cell_index_from_surrounding_cells(cell_map: Array, layer: int, cell_x: int, cell_y: int) -> int:
	var index: int = 0
	if cell_map[layer][cell_x][cell_y - 1] >= 0:
		index += 1
	if cell_map[layer][min(size_bordered-1, cell_x + 1)][cell_y] >= 0:
		index += 2
	if cell_map[layer][cell_x][min(size_bordered-1, cell_y + 1)] >= 0:
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
	if cell_map[layer][min(size_bordered-1, cell_x + 1)][cell_y - 1] < 0:
		index += 1
	if cell_map[layer][cell_x - 1][min(size_bordered-1, cell_y + 1)] < 0:
		index += 4
	if cell_map[layer][min(size_bordered-1, cell_x + 1)][min(size_bordered-1, cell_y + 1)] < 0:
		index += 2
	return index


func init_noise_chunk(chunk_coords: Vector2i) -> Array[Array]:
	var new_chunk: Array[Array] = []
	for layer in layer_count:
		var noise_level_minimum: float = 1.0 / (layer_count + 1) * (layer + 1)
		new_chunk.push_back([])
		for x in range(0, size_bordered):
			new_chunk[layer].push_back([])
			for y in range(0, size_bordered):
				var noise_level: float = (noise.get_noise_2d(chunk_coords.x - center + x, chunk_coords.y - center + y) + 1) / 2
				if noise_level > noise_level_minimum:
					new_chunk[layer][x].push_back(0)
					new_chunk[layer][max(0, x-1)][y] = 0
					new_chunk[layer][x][max(0, y-1)] = 0
					new_chunk[layer][max(0, x-1)][max(0, y-1)] = 0
				else:
					new_chunk[layer][x].push_back(-1)
	return new_chunk

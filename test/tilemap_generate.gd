extends Node2D

@onready var tile_map = $TileMap

var mapped_cells: Array = [[],[],[],[]]
var map_size := Vector2i(32, 32)

func _on_noise_generator_noise_generated(noise):
	mapped_cells = [[],[],[],[]]
	for x in range(-map_size.x, map_size.x):
		for y in range(-map_size.y, map_size.y):
			var noise_level = (noise.get_noise_2d(x, y) + 1) / 2
			var layer = get_cell_layer_from_noise(noise_level)
			tile_map.set_cell(layer, Vector2i(x,y), layer, Vector2i(2,2))
			mapped_cells[layer].append(Vector2i(x,y))
	
	for c in range(0, 4):
		tile_map.set_cells_terrain_connect(c, mapped_cells[c], 0, c)


func get_cell_layer_from_noise(value: float) -> int:
	if value > 0.75:
		return 3
	elif value > 0.50:
		return 2
	elif value > 0.25:
		return 1
	else:
		return 0

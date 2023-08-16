extends Node2D

@onready var tile_map = $TileMap

var mapped_cells: Array = []
var map_size := Vector2i(64, 64)

var noise_levels: Array = [0,0,0,0]

func _on_noise_generator_noise_generated(noise):
	mapped_cells = []
	tile_map.clear()
	for x in range(-map_size.x, map_size.x):
		for y in range(-map_size.y, map_size.y):
			var noise_level = (noise.get_noise_2d(x, y) + 1) / 2
			count_noise(noise_level)
			var layer = get_cell_layer_from_noise(noise_level)
			
			if noise_level > 0.50:
				mapped_cells.append(Vector2i(x,y))
				mapped_cells.append(Vector2i(x-1,y))
				mapped_cells.append(Vector2i(x,y-1))
				mapped_cells.append(Vector2i(x-1,y-1))
	
	print_noise_debug()
	tile_map.set_cells_terrain_connect(0, mapped_cells, 0, 0)



func count_noise(value: float) -> void:
	if value > 0.6:
		noise_levels[0] += 1
	elif value > 0.4:
		noise_levels[1] += 1
	elif value > 0.2:
		noise_levels[2] += 1
	else:
		noise_levels[3] += 1



func print_noise_debug() -> void:
	print("# ----------")
	print("> 0.6 - " + str(noise_levels[0]))
	print("> 0.4 - " + str(noise_levels[1]))
	print("> 0.2 - " + str(noise_levels[2]))
	print("< 0.2 - " + str(noise_levels[3]))
	print("\n")


func get_cell_layer_from_noise(value: float) -> int:
	if value > 0.75:
		return 0
	elif value > 0.50:
		return 1
	elif value > 0.25:
		return 2
	else:
		return 3

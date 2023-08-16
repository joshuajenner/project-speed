extends Node3D


@onready var tile_map: TileMap = %TileMap

@onready var level_1 = $"Level 1"
@onready var floor = $Floor

var map_size := Vector2i(64, 64)
var mapped_cells: Array = []



func _on_noise_generator_noise_generated(noise):
	mapped_cells = []
	tile_map.clear()
	for x in range(-map_size.x, map_size.x):
		for y in range(-map_size.y, map_size.y):
			var noise_level = (noise.get_noise_2d(x, y) + 1) / 2
			if noise_level > 0.50:
				mapped_cells.append(Vector2i(x,y))
				mapped_cells.append(Vector2i(x-1,y))
				mapped_cells.append(Vector2i(x,y-1))
				mapped_cells.append(Vector2i(x-1,y-1))
				
	tile_map.set_cells_terrain_connect(0, mapped_cells, 0, 0)

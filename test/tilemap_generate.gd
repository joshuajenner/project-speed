extends Node2D

#@onready var tile_map = $TileMap

var tile_map: TileMap
var tile_set: TileSet = load("res://test/tileset_gridmap.tres")

var mapped_cells: Array = [[],[]]
var map_size := Vector2i(16, 16)

var noise_levels: Array = [0,0,0,0]

var thread := Thread.new()



func _ready():
	tile_map = TileMap.new()
	tile_map.tile_set = tile_set
	tile_map.add_layer(-1)


func _on_noise_generator_noise_generated(noise: FastNoiseLite):
	thread.start(generate_tilemap.bind(noise))


func generate_tilemap(noise: FastNoiseLite) -> void:
	mapped_cells = [[],[]]
	tile_map.clear()
	for x in range(-map_size.x, map_size.x):
		for y in range(-map_size.y, map_size.y):
			var noise_level = (noise.get_noise_2d(x, y) + 1) / 2
			count_noise(noise_level)
			var layer = get_cell_layer_from_noise(noise_level)
			
			if noise_level > 0.60:
				mapped_cells[0].append(Vector2i(x,y))
#				mapped_cells[0].append(Vector2i(x-1,y))
#				mapped_cells[0].append(Vector2i(x,y-1))
#				mapped_cells[0].append(Vector2i(x-1,y-1))
			elif noise_level > 0.40:
				mapped_cells[1].append(Vector2i(x,y))
#				mapped_cells[1].append(Vector2i(x-1,y))
#				mapped_cells[1].append(Vector2i(x,y-1))
#				mapped_cells[1].append(Vector2i(x-1,y-1))
	
	print_noise_debug()
	tile_map.set_cells_terrain_connect(0, mapped_cells[0], 0, 0)
	tile_map.set_cells_terrain_connect(1, mapped_cells[1], 0, 1)
	self.call_deferred("add_child", tile_map)


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


func _exit_tree():
	thread.wait_to_finish()

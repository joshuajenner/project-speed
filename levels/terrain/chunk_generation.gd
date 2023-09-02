extends Node3D


var chunk_size: int = 24
var chunk_size_bordered: int = chunk_size + 2
var chunk_center: int = chunk_size / 2
var chunk_layer_count: int = 2
var minimum_distance_to_load_chunk: float = 130.0


var noise: FastNoiseLite
var noise_resource: NoiseResource = load("res://noise/cellular_1.tres")

var custom_cell_size = Vector3(0.99, 0.5, 0.99)
var custom_mesh_library = preload("res://test/mesh_library_gridmap.tres")

var thread: Thread


var placed_chunks: Dictionary = {}
var unready_chunks: Dictionary = {}


func _ready():
	noise = noise_resource.create_noise()
	thread = Thread.new()

func _physics_process(delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()


func update_chunks():
	var player_coords := Vector2i(Player.current_position.x, Player.current_position.z)
	var nearby_chunks_coords: Array[Vector2i] = get_chunks_within_minimum_distance_to_load(player_coords)
	for chunk_coord in nearby_chunks_coords:
		place_chunk(chunk_coord)

func clean_up_chunks():
	pass

func reset_chunks():
	pass




func update_chunks_to_solve(player_coords: Vector2i) -> void:
	var nearby_chunks_coords: Array[Vector2i] = get_chunks_within_minimum_distance_to_load(player_coords)
	for chunk_coord in nearby_chunks_coords:
		pass
#		if not chunks_to_solve.has(chunk_coord) and not placed_chunks.has(chunk_coord):
#			chunks_to_solve.push_back(chunk_coord)


func get_chunks_within_minimum_distance_to_load(player_coords: Vector2i) -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	
	var x = int((player_coords.x - minimum_distance_to_load_chunk) / chunk_size) * chunk_size + chunk_center
	while x < player_coords.x + minimum_distance_to_load_chunk:
		var y = int((player_coords.y - minimum_distance_to_load_chunk) / chunk_size) * chunk_size + chunk_center
		while y < player_coords.y + minimum_distance_to_load_chunk:
			coords.push_back(Vector2i(x, y))
			y += chunk_size
		x += chunk_size
	
	return coords


func place_chunk(coords: Vector2i) -> void:
	if placed_chunks.has(coords) or unready_chunks.has(coords):
		return
	
	if not thread.is_started():
		thread.start(load_chunk.bind(thread, coords))
		unready_chunks[coords] = 0


func load_chunk(thread, coords):
	var new_chunk = Chunk.new(noise, coords, chunk_size, chunk_layer_count)
	new_chunk.cell_size = custom_cell_size
	new_chunk.mesh_library = custom_mesh_library
	new_chunk.position = Vector3(coords.x, 0, coords.y)
	new_chunk.scale = Vector3(1.01, 1.01, 1.01)
	call_deferred("load_done", new_chunk, thread)


func load_done(chunk, thread):
	add_child(chunk)
	placed_chunks[chunk.coord] = chunk
	unready_chunks.erase(chunk.coord)
	thread.wait_to_finish()


func get_chunk(coords):
	if placed_chunks.has(coords):
		return placed_chunks.get(coords)
	
	return null

extends Node3D


var chunk_size: int = 32
var chunk_size_bordered: int = chunk_size + 2
var chunk_center: int = chunk_size / 2
var chunk_layer_count: int = 2

var noise: FastNoiseLite
var noise_resource: NoiseResource = load("res://noise/cellular_1.tres")


func _ready():
	noise = noise_resource.create_noise()
	
	var new_chunk = Chunk.new(noise, Vector2i.ZERO, chunk_size, chunk_layer_count)
	add_child(new_chunk)

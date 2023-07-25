extends Node3D


@onready var mesh_instance = $MeshInstance

@export var material : StandardMaterial3D
@export var radius: float = 0.1
@export var length: float = 1.5


func _ready() -> void:
	mesh_instance.material_override = material


func draw_line(end: Vector2) -> void:
	if end == Vector2.ZERO:
		remove_line()
		return
	
	end.y = -end.y
	
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = length
	
	mesh_instance.position.x = length/2
	mesh_instance.mesh = cylinder
	self.rotation_degrees.y = rad_to_deg(end.angle()) 


func remove_line() -> void:
	mesh_instance.mesh = null

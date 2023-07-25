extends CharacterBody3D


@onready var input_debug = $DebugParent/InputDebug
@onready var current_direction_debug = $DebugParent/CurrentDirectionDebug
@onready var ship_mesh_pivot = $ShipMeshPivot


@export var speed_base: int = 10
@export var speed_current: int = 100
@export var speed_max: int = 500

@export var accleration: int = 10
@export var turn_speed : float = 0.1

@export var direction_input: Vector2 = Vector2(0, 0)
@export var direction_current: Vector2 = Vector2(0, 1)

var input_is_active: bool = false


func _physics_process(delta):
	get_input()
	handle_flight()
	rotate_ship_mesh()


func get_input():
	direction_input.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	direction_input.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	direction_input = direction_input.normalized()
	
	input_is_active = vector2_not_zero(direction_input)
	# debug
	input_debug.draw_line(direction_input.normalized())


func vector2_not_zero(vector: Vector2) -> bool:
	if vector.x != 0 or vector.y != 0:
		return true
	else:
		return false


func handle_flight():
	if input_is_active:
		var input_angle = direction_input.angle()
		var current_angle = direction_current.angle()
		var new_angle = lerp_angle(current_angle, input_angle, turn_speed)
		direction_current = Vector2.from_angle(new_angle)
	
	velocity = Vector3(direction_current.x, 0, direction_current.y) * speed_base
	move_and_slide()
	
	#debug
	current_direction_debug.draw_line(direction_current)


func rotate_ship_mesh() -> void:
	var adjusted_vector = Vector2(direction_current.x, -direction_current.y) 
	ship_mesh_pivot.rotation.y = adjusted_vector.angle()

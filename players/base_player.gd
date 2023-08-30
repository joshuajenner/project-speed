class_name Player
extends CharacterBody3D

static var current_position := Vector3.ZERO

@onready var input_debug = $DebugParent/InputDebug
@onready var current_direction_debug = $DebugParent/CurrentDirectionDebug
@onready var ship_mesh_pivot = $ShipMeshPivot


@export var speed_base: int = 100
@export var speed_current: int = 100
@export var speed_max: int = 500

@export var accleration: int = 10
@export var turn_speed : float = 0.03

@export var direction_target: Vector2 = Vector2(0, 0)
@export var direction_current: Vector2 = Vector2(0, 1)

var has_active_target_direction: bool = false
var target_direction_reached: bool = false

var max_roll: float = 45


func _physics_process(delta):
	update_position()
	get_input()
	handle_flight()
	rotate_ship_mesh()

func update_position() -> void:
	current_position = global_position

func get_input():
	direction_target.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	direction_target.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	direction_target = direction_target.normalized()
	
	has_active_target_direction = vector2_not_zero(direction_target)
	
	# debug
	input_debug.draw_line(direction_target.normalized())


func vector2_not_zero(vector: Vector2) -> bool:
	if vector.x != 0 or vector.y != 0:
		return true
	else:
		return false


func handle_flight():
	if has_active_target_direction:
		var input_angle = direction_target.angle()
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
	
	if has_active_target_direction:
		var angle_to_target = rad_to_deg(direction_current.angle_to(direction_target))
		if abs(angle_to_target) > 20:
			lerp_add_ship_roll(angle_to_target)
		else:
			lerp_reset_ship_roll()
	else:
		lerp_reset_ship_roll()


func lerp_add_ship_roll(angle_to_target: float) -> void:
	if angle_to_target < 0:
		ship_mesh_pivot.rotation.x = lerpf(ship_mesh_pivot.rotation.x, deg_to_rad(-max_roll), 0.05)
	else:
		ship_mesh_pivot.rotation.x = lerpf(ship_mesh_pivot.rotation.x, deg_to_rad(max_roll), 0.05)


func lerp_reset_ship_roll() -> void:
	ship_mesh_pivot.rotation.x = lerpf(ship_mesh_pivot.rotation.x, 0, 0.1)

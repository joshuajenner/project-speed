class_name Player
extends CharacterBody3D

static var current_position := Vector3.ZERO

@onready var input_debug = $DebugParent/InputDebug
@onready var current_direction_debug = $DebugParent/CurrentDirectionDebug
@onready var ship_mesh_pivot = $ShipMeshPivot


@export var speed_base: float = 20.0
@export var speed_current: float = 20.0
@export var speed_max: float = 25.0

@export var acceleration: float = 0.03
@export var deceleration: float = 0.02
@export var turn_speed : float = 0.03

@export var direction_target: Vector2 = Vector2(0, 0)
@export var direction_current: Vector2 = Vector2(0, 1)

var has_active_target_direction: bool = false
var target_direction_reached: bool = false

var max_roll: float = 45


func _physics_process(delta):
	update_position()
	get_input()
	handle_flight(delta)
	rotate_ship_mesh()
	
	DebugMenu.display_value("Speed: ", speed_current)
	DebugMenu.display_value("Turning: ", has_active_target_direction)

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


func handle_flight(delta: float):
	if has_active_target_direction:
		var input_angle = direction_target.angle()
		var current_angle = direction_current.angle()
		
		var angle_to_target = direction_current.angle_to(direction_target)
		var new_angle: float
		
		DebugMenu.display_value("Input: ", input_angle)
		DebugMenu.display_value("Direction: ", angle_to_target)
		
		
		if abs(angle_to_target) <= 0.05:
			new_angle = input_angle
		elif angle_to_target < 0:
			new_angle =  current_angle - (PI/2 * turn_speed)
		else:
			new_angle = current_angle + (PI/2 * turn_speed)
		
		if abs(angle_to_target) < deg_to_rad(45.0):
			speed_current = lerpf(speed_current, speed_max, acceleration)
		else:
			speed_current = lerpf(speed_current, speed_base, deceleration)
		
		direction_current = Vector2.from_angle(new_angle)
#		speed_current = clamp((speed_current - (deceleration*delta)), speed_base, speed_max)
	else:
		speed_current = lerpf(speed_current, speed_max, acceleration)
#		speed_current = clamp((speed_current + (acceleration*delta)), speed_base, speed_max)
	
	velocity = Vector3(direction_current.x, 0, direction_current.y) * speed_current
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

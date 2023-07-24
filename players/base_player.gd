extends CharacterBody3D


@export var speed_base: int = 10
@export var speed_current: int = 100
@export var speed_max: int = 500

@export var accleration: int = 10
@export var turn_speed : int = 10

@export var direction_input: Vector2 = Vector2(0, 1)
@export var direction_current: Vector2


func _physics_process(delta):
	handle_input()
	handle_flight()


func _input(event):
	if event.is_action_pressed("move_up"):
		direction_input.y = 1
	if event.is_action_pressed("move_down"):
		direction_input.y = -1
	if event.is_action_pressed("move_left"):
		direction_input.x = -1
	if event.is_action_pressed("move_right"):
		direction_input.x = 1
	
	


func handle_input():
#	direction_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
#	direction_input.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	direction_input = direction_input.normalized()

func handle_flight():
	velocity = Vector3(direction_input.x, 0, direction_input.y) * speed_base
	move_and_slide()

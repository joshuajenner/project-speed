extends MeshInstance3D

@onready var trail_effect = $TrailEffect
@onready var timer = $Timer

@export var direction := Vector2.ZERO
@export var speed: float = 200.0


func _ready():
	timer.start()

func _physics_process(delta):
	rotation.y = direction.angle()
	global_position.x += direction.x * speed * delta
	global_position.z += direction.y * speed * delta

func _on_timer_timeout():
	self.queue_free()

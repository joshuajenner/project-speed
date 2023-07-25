extends CanvasLayer


@onready var main = $Main


func _ready() -> void:
	main.visible = false


func _input(event):
	if event.is_action_pressed("toggle_debug"):
		main.visible = !main.visible

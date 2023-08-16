extends CanvasLayer

var is_paused: bool = false


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if is_paused:
			is_paused = false
		else:
			is_paused = true
		get_tree().paused = is_paused

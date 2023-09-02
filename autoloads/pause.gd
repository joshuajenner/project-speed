extends CanvasLayer

var is_paused: bool = false

signal on_paused
signal on_resume

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if is_paused:
			set_resume()
		else:
			set_paused()


func set_paused() -> void:
	is_paused = true
	get_tree().paused = is_paused
	on_paused.emit()


func set_resume() -> void:
	is_paused = false
	get_tree().paused = is_paused
	on_resume.emit()

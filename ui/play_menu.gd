extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Pause.set_paused()
	Pause.on_paused.connect(show_menu)
	Pause.on_resume.connect(hide_menu)


func show_menu() -> void:
	self.visible = true

func hide_menu() -> void:
	self.visible = false

func _on_start_button_pressed():
	Pause.set_resume()
	hide_menu()

func _on_quit_button_pressed():
	get_tree().quit()

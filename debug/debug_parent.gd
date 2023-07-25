extends Node3D


func _ready():
	self.visible = false


func _input(event):
	if event.is_action_pressed("toggle_debug"):
		self.visible = !self.visible

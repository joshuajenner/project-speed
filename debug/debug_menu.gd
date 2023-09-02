extends CanvasLayer

@onready var layout = %VBox

var debug_item = load("res://debug/debug_item.tscn")

var debug_items_loaded: Array[String] = []

func _ready() -> void:
	visible = true


func _input(event):
	if event.is_action_pressed("toggle_debug"):
		visible = !visible


func display_value(label: String, value) -> void:
	if not debug_items_loaded.has(label):
		debug_items_loaded.push_back(label)
		var item_instance = debug_item.instantiate()
		item_instance.set_label(label)
		item_instance.set_value(value)
		layout.add_child(item_instance)
	else:
		for item in layout.get_children():
			if item.get_label() == label:
				item.set_value(value)

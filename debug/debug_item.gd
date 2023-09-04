extends MarginContainer

func get_label() -> String:
	return $Label.text

func set_label(new_label: String) -> void:
	$Label.text = new_label


func set_value(new_value) -> void:
	if new_value is Vector2:
		$Value.text = str(new_value.x) + " / " + str(new_value.y)
	elif new_value is Vector3:
		$Value.text = str(new_value.x) + " / " + str(new_value.y) + " / " + str(new_value.z)
	elif new_value is float:
		$Value.text = str(snappedf(new_value, 0.01))
	else:
		$Value.text = str(new_value)

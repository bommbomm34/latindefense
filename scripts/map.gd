extends Control

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or event is InputEventScreenDrag:
		var addition = -Input.get_last_mouse_velocity() * get_process_delta_time()
		var result = $Camera2D.position + addition
		if not (result.x < 480 or result.x > 1439 or result.y < 271 or result.y > 809):
			$Camera2D.position = result

extends Control

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or event is InputEventScreenDrag:
		$Camera2D.position += -Input.get_last_mouse_velocity() * get_process_delta_time()

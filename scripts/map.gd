extends Control

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or event is InputEventScreenDrag:
		var addition = -Input.get_last_mouse_velocity() * get_process_delta_time()
		$Camera2D.position += addition * 0.5

func _process(_delta: float) -> void:
	$Base.position = get_node("Camera2D").get_screen_center_position() - get_viewport_rect().size / 4.0

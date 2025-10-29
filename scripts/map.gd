extends Control

const DRAG_SPEED = 50
var dragging = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		$Camera2D.position += -event.screen_relative * DRAG_SPEED * get_process_delta_time()

func _process(_delta: float) -> void:
	$Base.position = get_node("Camera2D").get_screen_center_position() - get_viewport_rect().size / 4.0

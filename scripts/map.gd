extends Control

const DESKTOP_DRAG_SPEED = 40
const MOBILE_DRAG_SPEED = 30
var drag_speed = DESKTOP_DRAG_SPEED
var dragging = false

func _ready() -> void:
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		drag_speed = MOBILE_DRAG_SPEED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		$Camera2D.position += -event.screen_relative * drag_speed * get_process_delta_time()

func _process(_delta: float) -> void:
	$Base.position = get_node("Camera2D").get_screen_center_position() - get_viewport_rect().size / 4.0

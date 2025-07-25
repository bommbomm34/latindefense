@tool
class_name Province
extends Area2D

static var open_popup: Node2D = null
var hover = false
var active = false
var denar := 0
var soldier_count := 0
@onready var owned = Database.get_value(name + "_owned", false)
@onready var polygon: CollisionPolygon2D = get_child(0)
@onready var life: int = Database.get_value(name + "_life", 7000)
@export var custom_neighbor_states: Array
var color := Color(Color(0, 0, 0), 0.5):
	set(value):
		color = value
		color.a = 0.5
		if polygon != null:
			polygon.queue_redraw()

func _ready() -> void:
	if polygon != null:
		polygon.draw.connect(_on_polygon_draw)
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		area_entered.connect(_on_area_entered)
	else:
		push_error("Failed to connect signals. No polygon is set.")
	load_values()
	Database.set_value(name + "_denar", denar)
	Database.set_value(name + "_soldier_count", soldier_count)
	if owned:
		color = Color.CADET_BLUE
	else:
		color = Color.BLUE_VIOLET
	open_popup = get_node("../../Camera2D/Popup")
	#var size := get_province_size()
	#var calc_denar = roundi(size.x)
	#var calc_soldier_count = roundi(size.y)
	#print("\"{0}\",\"{1}\",\"{2}\",\"{3}\"".format([name, calc_denar, calc_soldier_count, size]))

func _on_polygon_draw():
	if polygon.polygon.size() > 2:
		polygon.draw_colored_polygon(polygon.polygon, color)

func _on_mouse_entered():
	if not (OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")):
		if active:
			color.r = 1
			hover = true

func _on_mouse_exited():
	if active:
		color.r = 0
		hover = false

func _process(delta: float) -> void:
	if not owner == get_tree().edited_scene_root:
		if active:
			color.b = 1 if open_popup.province_name == name and open_popup.visible else 0
		if not owned and not active:
			for province_path in custom_neighbor_states:
				if get_node(province_path).owned:
					active = true
					color = Color.BLACK
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if active:
		if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if open_popup.visible:
				set_popup(null if open_popup.province_name == name else name, denar, soldier_count, life)
			else:
				set_popup(name, denar, soldier_count, life)
func _on_area_entered(area: Area2D):
	if area is Province and area.owned and not owned:
		active = true
		color = Color.BLACK

func set_popup(given_name, given_denar: int, given_soldier_count: int, given_life: int):
	if given_name:
		open_popup.province_name = given_name
		open_popup.denar = given_denar
		open_popup.soldier_count = given_soldier_count
		open_popup.life = given_life
	open_popup.visible = given_name != null

#func get_province_size() -> Vector2:
	#var base := Vector2(0, 0)
	#var points := polygon.polygon
	#var lowest_point := Vector2(2000, 2000)
	#var highest_point := Vector2(-1, -1)
	#for point in points:
		#if point.x < lowest_point.x:
			#lowest_point.x = point.x
		#if point.x > highest_point.x:
			#highest_point.x = point.x
		#if point.y < lowest_point.y:
			#lowest_point.y = point.y
		#if point.y > highest_point.y:
			#highest_point.y = point.y
	#return Vector2(highest_point.x - lowest_point.x, highest_point.y - lowest_point.y)

func load_values():
	var file := FileAccess.open("res://assets/map/values.txt", FileAccess.READ)
	while file.get_position() < file.get_length():
		var array := file.get_csv_line()
		if array.get(0) == name:
			denar = int(array.get(1))
			soldier_count = int(array.get(2))
			break
	

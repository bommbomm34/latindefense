extends Control

@onready var file := FileAccess.open("res://assets/vocabs/vocabs_" + get_real_language() + ".txt", FileAccess.READ)
var right_option: String
const reward = 50

func _ready() -> void:
	var imported_pos = Database.get_value("vocabs_position", 0)
	file.seek(0 if imported_pos >= file.get_length() else imported_pos)
	read_vocabs_line()

func _on_option_1_pressed() -> void:
	$Option1.release_focus()
	select($Option1.text)

func _on_option_2_pressed() -> void:
	$Option2.release_focus()
	select($Option2.text)

func _on_option_3_pressed() -> void:
	$Option3.release_focus()
	select($Option3.text)

func _on_option_4_pressed() -> void:
	$Option4.release_focus()
	select($Option4.text)

func select(option: String):
	if option == right_option:
		right()
	else:
		wrong()
	var result = read_vocabs_line()
	if not result:
		end()
	else:
		clear_later()
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		call_deferred("release_hover_state")

func right():
	Database.add_value("denar", reward)
	$Feedback.text = "Right"
	$Feedback.add_theme_color_override("font_color", Color.GREEN)
	
func wrong():
	Database.add_value("denar", get_anti_reward())
	$Feedback.text = "Wrong"
	$Feedback.add_theme_color_override("font_color", Color.RED)

func get_anti_reward():
	@warning_ignore("integer_division")
	var anti_reward: int = reward / -2
	return 0 if Database.get_value("denar", 0) < abs(anti_reward) else anti_reward

func read_vocabs_line() -> bool:
	Database.set_value("vocabs_position", file.get_position())
	if file.get_position() < file.get_length():
		$Instruction.visible = file.get_position() == 0
		var line_array: Array = file.get_csv_line()
		$SourceWord.text = line_array.get(0)
		line_array.remove_at(0)
		right_option = line_array.get(0)
		line_array.shuffle()
		$Option1.text = line_array.get(0)
		$Option2.text = line_array.get(1)
		$Option3.text = line_array.get(2)
		$Option4.text = line_array.get(3)
		return true
	else:
		return false

func end():
	$Option1.disabled = true
	$Option2.disabled = true
	$Option3.disabled = true
	$Option4.disabled = true
	$SourceWord.text = ""
	$Feedback.text = "No vocabs left. Restarting."
	await get_tree().create_timer(3.0).timeout
	Database.set_value("vocabs_position", 0)
	read_vocabs_line()

func clear_later():
	await get_tree().create_timer(3.0).timeout
	$Feedback.text = ""

func release_hover_state(): # We do this to make it more pretty on touch screen devices
	var click = InputEventMouseButton.new()
	click.position = Vector2(1920, 1080)
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	Input.parse_input_event(click)
	await get_tree().process_frame
	click.pressed = false
	Input.parse_input_event(click)

func get_real_language() -> String:
	var lang = Database.get_value("lang", "auto")
	return lang if lang != "auto" else OS.get_locale_language() if FileAccess.file_exists("res://assets/vocabs/vocabs_" + OS.get_locale_language() + ".txt") else "en"

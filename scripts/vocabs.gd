extends Control

@onready var file := FileAccess.open("res://assets/vocabs/vocabs_" + get_real_language() + ".txt", FileAccess.READ)
var right_option: String
var cards = []
var review_cards = []
var current_card = null
var all_answers = []
const reward = 50

func _ready() -> void:
	load_cards()
	apply_vocab()

func load_cards():
	cards.clear()
	all_answers.clear()
	var saved_cards = Database.get_value("cards", null)
	if saved_cards == null:
		while file.get_position() < file.get_length():
			var csv = file.get_csv_line()
			_append_card(Card.new(csv[0], csv[1]))
		save_cards()
	else:
		for serialized_card in saved_cards:
			_append_card(Card.deserialize(serialized_card))

func _append_card(card: Card):
	all_answers.append(card.answer)
	cards.append(card)
	if card.needs_review():
		review_cards.append(card)

func save_cards():
	var serialized_cards = []
	for card in cards:
		serialized_cards.append(card.serialize())
	Database.set_value("cards", serialized_cards)

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
	review_current_card(option == right_option)
	if option == right_option:
		right()
	else:
		wrong()
	var result = apply_vocab()
	if not result:
		end()
	else:
		clear_later()
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		call_deferred("release_hover_state")

func review_current_card(correct_response: bool):
	current_card.review(4 if correct_response else 0)
	var occurence = cards.find_custom(func (card): return card.question == current_card.question)
	var occurence_review = review_cards.find_custom(func (card): return card.question == current_card.question)
	cards.erase(occurence)
	review_cards.erase(occurence_review)
	cards.append(current_card)
	save_cards()

func right():
	Database.add_value("denar", reward)
	$Feedback.text = "Right"
	$Feedback.add_theme_color_override("font_color", Color.GREEN)
	
func wrong():
	Database.add_value("denar", get_anti_reward())
	$Feedback.text = tr("Wrong. Right: ") + right_option
	$Feedback.add_theme_color_override("font_color", Color.RED)

func get_anti_reward():
	@warning_ignore("integer_division")
	var anti_reward: int = reward / -2
	return 0 if Database.get_value("denar", 0) < abs(anti_reward) else anti_reward

func apply_vocab() -> bool:
	if not review_cards.is_empty():
		# Show instruction if all cards need to be reviewed
		$Instruction.visible = all_answers.size() == review_cards.size()
		current_card = review_cards.pick_random()
		$SourceWord.text = current_card.question
		right_option = current_card.answer
		all_answers.shuffle()
		var possible_answers := all_answers.duplicate().filter(func (answer): return answer != right_option)
		possible_answers.resize(3)
		possible_answers.append(right_option)
		possible_answers.shuffle()
		$Option1.text = possible_answers.get(0)
		$Option2.text = possible_answers.get(1)
		$Option3.text = possible_answers.get(2)
		$Option4.text = possible_answers.get(3)
		return true
	else:
		return false

func end():
	$Option1.disabled = true
	$Option2.disabled = true
	$Option3.disabled = true
	$Option4.disabled = true
	$SourceWord.text = ""
	$Feedback.text = "No vocabs left. See you later!"

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

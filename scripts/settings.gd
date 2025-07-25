extends Control

@onready var music_slider = $ScrollContainer/Settings/Volume/MusicSlider
@onready var sfx_slider = $ScrollContainer/Settings/Volume/SFXSlider
@onready var bg_color_button = $ScrollContainer/Settings/Theme/ColorPicker
const lang_short := ["auto", "de", "en", "tr"]
const lang_long := ["Automatic", "German", "English", "Türkçe"]

func _ready():
	music_slider.value = Database.get_value("music_volume", 100)
	sfx_slider.value = Database.get_value("sfx_volume", 100)
	bg_color_button.color = Database.get_value("bg_color", Color("036462"))
	var reset_warning_translation = tr("RESET_WARNING")
	if reset_warning_translation != "RESET_WARNING":
		$ScrollContainer/Settings/Reset/Warning.text = reset_warning_translation
	$ScrollContainer/Settings/Language/OptionButton.selected = lang_short.find(Database.get_value("lang", "auto"))
	RenderingServer.set_default_clear_color(bg_color_button.color)

func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Database.set_value("music_volume", music_slider.value)
		
func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Database.set_value("sfx_volume", sfx_slider.value)


func _on_reset_button_pressed() -> void:
	Database.remove_all()
	call_deferred("change_to_scene", "res://scenes/Home.tscn")


func _on_color_picker_color_changed(color: Color) -> void:
	Database.set_value("bg_color", color)
	RenderingServer.set_default_clear_color(color)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_P:
		Database.add_value("denar", 1000)

func change_to_scene(path: String):
	get_tree().change_scene_to_file(path)


func _on_language_selected(index: int) -> void:
	Database.set_value("lang", lang_short[lang_long.find($ScrollContainer/Settings/Language/OptionButton.get_item_text(index))])
	Database.set_value("vocabs_position", 0)
	call_deferred("change_to_scene", "res://scenes/Home.tscn")

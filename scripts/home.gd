extends Control

const default_map_position := Vector2(49, 153)
const default_map_size := Vector2(837, 650)

func _ready():
	#Database.remove_all() # ONLY FOR DEBUGGING
	set_language()
	Database.set_default_value("soldier_common_amount", 21)
	Database.set_default_value("soldier_rare_amount", 6)
	Database.set_default_value("soldier_legendary_amount", 3)
	Database.set_default_value("self_life", 7000)
	Database.set_default_value("sfx_volume", 7)
	Database.set_value("Italia_owned", true)
	$SelfLifeLabel.text = str(Database.get_value("self_life", 7000))
	RenderingServer.set_default_clear_color(Database.get_value("bg_color", Color("036462")))
	
	var file := FileAccess.open("res://HELP.md", FileAccess.READ)
	$Help.markdown_text = file.get_as_text()

func _on_about_button_pressed() -> void:
	call_deferred("change_to_scene", "res://scenes/About.tscn")


func _on_settings_button_pressed() -> void:
	call_deferred("change_to_scene", "res://scenes/Settings.tscn")


func _on_vocabs_button_pressed() -> void:
	call_deferred("change_to_scene", "res://scenes/Vocabs.tscn")


func _on_resources_button_pressed() -> void:
	call_deferred("change_to_scene", "res://scenes/Resources.tscn")

func _on_map_button_pressed() -> void:
	call_deferred("change_to_scene", "res://scenes/Map.tscn")

func change_to_scene(path: String):
	get_tree().change_scene_to_file(path)

func set_language():
	var lang = Database.get_value("lang", "auto")
	if lang == "auto":
		TranslationServer.set_locale(OS.get_locale_language())
	else:
		TranslationServer.set_locale(lang)

func _on_help_button_toggled(toggled_on: bool) -> void:
	$Help.visible = toggled_on

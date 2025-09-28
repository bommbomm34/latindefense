extends Node2D

var province_name := "":
	set(value):
		province_name = value
		update_label()
var denar := 0:
	set(value):
		denar = value
		update_label()
var soldier_count := 0:
	set(value):
		soldier_count = value
		update_label()
var life := 7000:
	set(value):
		life = value
		update_label()

func update_label():
	var name_to_view = (province_name.substr(0, 15) + ".") if province_name.length() > 15 else province_name
	$ColorRect/MarkdownLabel.markdown_text = "# {0}
### {1} [img=40x40]res://assets/icons/denar.png[/img]		{2} [img=20]res://assets/soldiers/soldier_common.svg[/img]		[color=ff0000]{3}[/color]".format([name_to_view, denar, soldier_count, life])


func _on_fight_button_pressed() -> void:
	Database.set_temp_var("fight_against", province_name)
	call_deferred("change_to_scene", "res://scenes/Game.tscn")

func change_to_scene(path: String):
	get_tree().change_scene_to_file(path)

func _process(delta: float) -> void:
	var screen_size = get_viewport_rect().size
	position = get_node("../Camera2D").get_screen_center_position() + Vector2(screen_size.x / 4.0 - $ColorRect.size.x, screen_size.y / -4.0)

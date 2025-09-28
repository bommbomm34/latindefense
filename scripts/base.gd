@tool
extends Control

@export var denar_view_visiblity = true:
	get:
		return $DenarView.visible
	set(value):
		$DenarView.visible = value

func _on_pressed() -> void:
	call_deferred("change_to_scene", "res://scenes/Home.tscn")

func change_to_scene(path: String):
	get_tree().change_scene_to_file(path)

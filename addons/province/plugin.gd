@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("Province", "Area2D", preload("res://addons/province/province.gd"), preload("res://addons/province/resources.svg"))


func _exit_tree() -> void:
	remove_custom_type("Province")

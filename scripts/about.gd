extends Control

func _ready():
	var file := FileAccess.open("res://LICENSE.md", FileAccess.READ)
	$Content.markdown_text = file.get_as_text()

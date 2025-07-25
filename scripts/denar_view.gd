extends Control

func _ready() -> void:
	load_denar_amount()

func _process(_delta: float) -> void:
	load_denar_amount()

func load_denar_amount():
	$InfoLabel.text = str(Database.get_value("denar", 0)) + " [img=80x80]res://assets/icons/denar.png[/img]"

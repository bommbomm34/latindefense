class_name Database

extends Node

static var dictionary = {}
static var temp_dictionary = {}
const file_path = "user://data.save"

static func set_value(key: String, value):
	dictionary.set(key, value)
	flush_state()

static func remove(key: String):
	dictionary.erase(key)
	flush_state()

static func remove_all():
	dictionary.clear()
	flush_state()

static func add_value(key: String, value):
	set_value(key, get_value(key, 0) + value)

static func get_value(key: String, default):
	var value = dictionary.get(key)
	if value == null:
		set_value(key, default)
		return default
	else:
		return value

static func load_state():
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		dictionary = file.get_var()

static func flush_state():
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_var(dictionary)

static func set_default_value(key: String, value):
	if get_value(key, null) == null:
		set_value(key, value)

static func set_temp_var(key: String, value):
	temp_dictionary.set(key, value)

static func get_temp_var(key: String, default):
	var value = temp_dictionary.get(key)
	if value == null:
		set_temp_var(key, default)
		return default
	else:
		return value

static func get_owned_provinces() -> int:
	var owned_provinces := 0
	for key: String in dictionary:
		if key.ends_with("_owned"):
			owned_provinces += 1
	return owned_provinces

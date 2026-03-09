extends Node

const SAVE_PATH = "user://settings.cfg"
var _data: Dictionary = {}

func _ready() -> void:
	_load()

func get_setting(key: String, default):
	return _data.get(key, default)

func set_setting(key: String, value) -> void:
	_data[key] = value
	_save()

func _save() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_data))
	file.close()

func _load() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var text = file.get_as_text()
		file.close()
		_data = JSON.parse_string(text)

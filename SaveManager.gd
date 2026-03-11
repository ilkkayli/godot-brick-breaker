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

func update_highest_level(episode: int, level: int) -> void:
	var key = "highest_ep%d_level" % episode
	var current = get_setting(key, 0)
	if level > current:
		set_setting(key, level)

func get_highest_level(episode: int) -> int:
	return get_setting("highest_ep%d_level" % episode, 0)

func is_episode_unlocked(episode: int) -> bool:
	if episode == 1:
		return true
	var prev_levels = get_episode_level_count(episode - 1)
	return get_highest_level(episode - 1) >= prev_levels

func get_episode_level_count(episode: int) -> int:
	match episode:
		1: return 4
		2: return 5
		3: return 4
		4: return 5
	return 0

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

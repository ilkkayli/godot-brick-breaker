extends Node

const SAVE_PATH = "user://settings.cfg"
var _data: Dictionary = {}

const EPISODE_DATA = {
	1: {
		"name": "Outer Rim",
		"levels": 5,
		"level_names": {
			1: "First Debris",
			2: "Broken Ring",
			3: "Asteroid Gate",
			4: "Crystal Reactor",
			5: "Asteroid Core"
		}
	},
	2: {
		"name": "Alien Fleet",
		"levels": 5,
		"level_names": {
			1: "Defense Grid",
			2: "Reactor Pipes",
			3: "Hangar Bay",
			4: "Core Entrance",
			5: "Power Core"
		}
	},
	3: {
		"name": "Planetfall",
		"levels": 4,
		"level_names": {
			1: "Landing Zone",
			2: "Crystal Forest",
			3: "Ancient Ruins",
			4: "Alien City"
		}
	},
	4: {
		"name": "Orbital Station",
		"levels": 5,
		"level_names": {
			1: "Docking Bay",
			2: "Cargo Ring",
			3: "Security Grid",
			4: "Control Core",
			5: "Station Collapse"
		}
	}
}

func get_episode_level_count(episode: int) -> int:
	return EPISODE_DATA[episode]["levels"]

func get_episode_name(episode: int) -> String:
	return EPISODE_DATA[episode]["name"]

func get_level_name(episode: int, level: int) -> String:
	return EPISODE_DATA[episode]["level_names"].get(level, "Level " + str(level))

func get_total_episodes() -> int:
	return EPISODE_DATA.size()

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

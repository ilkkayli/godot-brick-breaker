extends Control
class_name LevelComplete

signal next_level
signal go_to_menu

static var current_level: int = 1
static var current_score: int = 0
static var current_episode: int = 1
static var episode_complete: bool = false

func _ready() -> void:
	$VBoxContainer/NextLevelButton.pressed.connect(_on_next_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

	var ep_name = SaveManager.get_episode_name(current_episode)

	if episode_complete:
		$VBoxContainer/LevelCompleteLabel.text = "EPISODE COMPLETE!"
		$VBoxContainer/LevelInfoLabel.text = "Episode %d\n%s" % [current_episode, ep_name]
		$VBoxContainer/NextLevelButton.text = "NEXT EPISODE"
	else:
		var level_name = SaveManager.get_level_name(current_episode, current_level)
		$VBoxContainer/LevelCompleteLabel.text = "LEVEL COMPLETE!"
		$VBoxContainer/LevelInfoLabel.text = "Ep.%d — %s\nLevel %d: %s" % [current_episode, ep_name, current_level, level_name]

	$VBoxContainer/ScoreLabel.text = "Score: " + str(current_score)
	size = get_viewport_rect().size
	position = Vector2.ZERO
	
func _on_next_pressed() -> void:
	if episode_complete:
		# Siirry seuraavaan episodiin
		var next_episode = current_episode + 1
		SaveManager.set_setting("current_episode", next_episode)
		SaveManager.set_setting("current_level", 1)
		SaveManager.set_setting("current_score", 0)
	get_tree().call_deferred("change_scene_to_file", "res://main.tscn")

func _on_menu_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://MainMenu.tscn")

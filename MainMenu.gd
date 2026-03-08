extends Control

const MAIN_SCENE = "res://main.tscn"

func _ready() -> void:
	var high_score = load_high_score()
	$VBoxContainer/HighScoreLabel.text = "Best: " + str(high_score)
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	print("Play pressed")
	get_tree().call_deferred("change_scene_to_file", "res://main.tscn")

func _on_settings_pressed() -> void:
	print("Settings - toteutetaan myöhemmin")

func _on_quit_pressed() -> void:
	get_tree().quit()

func load_high_score() -> int:
	if FileAccess.file_exists("user://save.dat"):
		var file = FileAccess.open("user://save.dat", FileAccess.READ)
		var score = file.get_32()
		file.close()
		return score
	return 0

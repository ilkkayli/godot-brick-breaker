extends Control

const MAIN_SCENE = "res://main.tscn"

func _ready() -> void:
	var font = load("res://assets/fonts/orbitron.ttf")
	var high_score = load_high_score()
	
	$VBoxContainer/HighScoreLabel.text = "Best: " + str(high_score)
	
	for btn in [$VBoxContainer/PlayButton, $VBoxContainer/DailyChallengeButton,
				$VBoxContainer/SettingsButton, $VBoxContainer/QuitButton]:
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 22)
		btn.custom_minimum_size = Vector2(300, 60)
	
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/DailyChallengeButton.pressed.connect(_on_daily_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_daily_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://DailyChallengeInfo.tscn")

func _on_play_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://DifficultySelect.tscn")

func _change_to_main() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _on_settings_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Settings.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func load_high_score() -> int:
	if FileAccess.file_exists("user://save.dat"):
		var file = FileAccess.open("user://save.dat", FileAccess.READ)
		var score = file.get_32()
		file.close()
		return score
	return 0

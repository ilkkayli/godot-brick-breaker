extends Control
class_name LevelComplete

signal next_level
signal go_to_menu

static var current_level: int = 1
static var current_score: int = 0

func _ready() -> void:
	$VBoxContainer/NextLevelButton.pressed.connect(_on_next_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)
	$VBoxContainer/LevelInfoLabel.text = "Level " + str(current_level - 1) + " → " + str(current_level)
	$VBoxContainer/ScoreLabel.text = "Score: " + str(current_score)

func _on_next_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://main.tscn")

func _on_menu_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://MainMenu.tscn")

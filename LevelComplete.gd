extends Control

signal next_level
signal go_to_menu

func _ready() -> void:
	$VBoxContainer/NextLevelButton.pressed.connect(_on_next_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func setup(current_level: int, score: int) -> void:
	$VBoxContainer/LevelInfoLabel.text = "Level " + str(current_level - 1) + " → " + str(current_level)
	$VBoxContainer/ScoreLabel.text = "Score: " + str(score)

func _on_next_pressed() -> void:
	next_level.emit()

func _on_menu_pressed() -> void:
	go_to_menu.emit()

extends Control

signal resume_game
signal go_to_menu

func _ready() -> void:
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_resume_pressed() -> void:
	resume_game.emit()

func _on_menu_pressed() -> void:
	go_to_menu.emit()

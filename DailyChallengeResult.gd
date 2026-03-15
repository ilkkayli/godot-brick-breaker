extends Control

static var final_score: int = 0

func _ready() -> void:
	var font = load("res://assets/fonts/orbitron.ttf")
	$VBoxContainer/TitleLabel.text = "DAILY CHALLENGE"
	$VBoxContainer/ResultLabel.text = "COMPLETE!"
	$VBoxContainer/ScoreLabel.text = "Score: " + str(final_score)
	
	for node in [$VBoxContainer/TitleLabel, $VBoxContainer/ResultLabel,
				 $VBoxContainer/ScoreLabel]:
		node.add_theme_font_override("font", font)
		
	for btn in [$VBoxContainer/RetryButton, $VBoxContainer/MenuButton]:
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 22)
	
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#00E5FF"))
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 28)
	$VBoxContainer/ResultLabel.add_theme_color_override("font_color", Color("#FFD700"))
	$VBoxContainer/ResultLabel.add_theme_font_size_override("font_size", 36)
	$VBoxContainer/ScoreLabel.add_theme_font_size_override("font_size", 24)
	
	$VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_retry_pressed() -> void:
	final_score = 0
	DailyChallenge.is_active = true
	get_tree().call_deferred("change_scene_to_file", "res://main.tscn")

func _on_menu_pressed() -> void:
	DailyChallenge.is_active = false
	get_tree().call_deferred("change_scene_to_file", "res://MainMenu.tscn")

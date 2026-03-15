extends Control

func _ready() -> void:
	DailyChallenge.setup()
	
	var font = load("res://assets/fonts/orbitron.ttf")
	var date = Time.get_date_string_from_system()
	
	$VBoxContainer/TitleLabel.text = "DAILY CHALLENGE"
	$VBoxContainer/DateLabel.text = date
	$VBoxContainer/ModifierLabel.text = "Modifier: " + DailyChallenge.modifier["name"]
	$VBoxContainer/DescLabel.text = DailyChallenge.modifier["desc"]
	$VBoxContainer/GoalLabel.text = "Goal: Score as many points as possible"
	
	for node in [$VBoxContainer/TitleLabel, $VBoxContainer/DateLabel,
				 $VBoxContainer/ModifierLabel, $VBoxContainer/DescLabel,
				 $VBoxContainer/GoalLabel]:
		node.add_theme_font_override("font", font)
		
	for btn in [$VBoxContainer/PlayButton, $VBoxContainer/BackButton]:
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 22)
	
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 28)
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#00E5FF"))
	$VBoxContainer/DateLabel.add_theme_font_size_override("font_size", 20)
	$VBoxContainer/DateLabel.add_theme_color_override("font_color", Color("#FFD700"))
	$VBoxContainer/ModifierLabel.add_theme_font_size_override("font_size", 20)
	$VBoxContainer/ModifierLabel.add_theme_color_override("font_color", Color("#FF9E00"))
	$VBoxContainer/DescLabel.add_theme_font_size_override("font_size", 16)
	$VBoxContainer/GoalLabel.add_theme_font_size_override("font_size", 16)
	
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_play_pressed() -> void:
	DailyChallenge.is_active = true
	get_tree().call_deferred("change_scene_to_file", "res://main.tscn")

func _on_back_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://MainMenu.tscn")

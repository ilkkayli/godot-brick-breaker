extends Control

func _ready() -> void:
	var font = load("res://assets/fonts/orbitron.ttf")
	
	var easy_btn = $VBoxContainer/EasyButton
	var normal_btn = $VBoxContainer/NormalButton
	var hard_btn = $VBoxContainer/HardButton
	
	var title = $VBoxContainer/TitleLabel
	title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#00E5FF"))
	
	for btn in [easy_btn, normal_btn, hard_btn]:
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 24)
	
	easy_btn.add_theme_color_override("font_color", Color("#00E676"))   # vihreä
	normal_btn.add_theme_color_override("font_color", Color("#FFD700")) # keltainen
	hard_btn.add_theme_color_override("font_color", Color("#FF1744"))   # punainen
	
	easy_btn.pressed.connect(_on_easy_pressed)
	normal_btn.pressed.connect(_on_normal_pressed)
	hard_btn.pressed.connect(_on_hard_pressed)

func _on_easy_pressed() -> void:
	SaveManager.set_setting("difficulty", "easy")
	get_tree().call_deferred("change_scene_to_file", "res://LevelSelect.tscn")

func _on_normal_pressed() -> void:
	SaveManager.set_setting("difficulty", "normal")
	get_tree().call_deferred("change_scene_to_file", "res://LevelSelect.tscn")

func _on_hard_pressed() -> void:
	SaveManager.set_setting("difficulty", "hard")
	get_tree().call_deferred("change_scene_to_file", "res://LevelSelect.tscn")

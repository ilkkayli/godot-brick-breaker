extends Control

func _ready() -> void:
	print("LevelSelect _ready")
	print("BackButton: ", $BackButton)
	$BackButton.pressed.connect(_on_back_pressed)
	_build_list()

func _build_list() -> void:
	var container = $ScrollContainer/VBoxContainer
	var font = load("res://assets/fonts/orbitron.ttf")

	for ep_number in range(1, SaveManager.get_total_episodes() + 1):
		var unlocked = SaveManager.is_episode_unlocked(ep_number)
		var highest = SaveManager.get_highest_level(ep_number)
		var ep_name = "Episode %d — %s" % [ep_number, SaveManager.get_episode_name(ep_number)]
		var level_count = SaveManager.get_episode_level_count(ep_number)

		var ep_label = Label.new()
		ep_label.text = ep_name if unlocked else "🔒 " + ep_name
		ep_label.add_theme_font_override("font", font)
		ep_label.add_theme_font_size_override("font_size", 20)
		if unlocked:
			ep_label.add_theme_color_override("font_color", Color("#FFD700"))
		else:
			ep_label.add_theme_color_override("font_color", Color("#555555"))
		ep_label.custom_minimum_size = Vector2(400, 40)
		container.add_child(ep_label)

		var grid = GridContainer.new()
		grid.columns = 5
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		container.add_child(grid)

		for lv in range(1, level_count + 1):
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(70, 60)
			btn.add_theme_font_override("font", font)
			btn.add_theme_font_size_override("font_size", 18)
			if unlocked and lv <= highest + 1:
				btn.text = str(lv)
				btn.add_theme_color_override("font_color", Color("#00E5FF"))
				btn.pressed.connect(_on_level_pressed.bind(ep_number, lv))
			else:
				btn.text = "🔒"
				btn.disabled = true
				btn.add_theme_color_override("font_color", Color("#555555"))
			grid.add_child(btn)

		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 20)
		container.add_child(spacer)

func _on_level_pressed(episode: int, level: int) -> void:
	SaveManager.set_setting("current_episode", episode)
	SaveManager.set_setting("current_level", level)
	SaveManager.set_setting("current_score", 0)
	get_tree().call_deferred("change_scene_to_file", "res://main.tscn")

func _on_back_pressed() -> void:
	print("Back pressed")
	get_tree().call_deferred("change_scene_to_file", "res://MainMenu.tscn")

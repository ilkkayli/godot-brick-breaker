extends Control
class_name LevelSelect

const TOTAL_LEVELS = 10

func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)
	_build_grid()

func _build_grid() -> void:
	print("Grid node: ", $GridContainer)
	var highest_level = SaveManager.get_setting("highest_level", 1)
	print("Highest level: ", highest_level)
	var grid = $GridContainer

	for i in range(1, TOTAL_LEVELS + 1):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(120, 80)
		btn.text = str(i)

		# Aseta fontti
		var font = load("res://assets/fonts/orbitron.ttf")
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 20)

		if i <= highest_level:
			# Avattu kenttä
			btn.add_theme_color_override("font_color", Color("#00E5FF"))
			btn.pressed.connect(_on_level_pressed.bind(i))
		else:
			# Lukittu kenttä
			btn.text = "🔒"
			btn.disabled = true
			btn.add_theme_color_override("font_color", Color("#555555"))

		grid.add_child(btn)

func _on_level_pressed(level_number: int) -> void:
	SaveManager.set_setting("current_level", level_number)
	SaveManager.set_setting("current_score", 0)
	get_tree().call_deferred("change_scene_to_file", "res://main.tscn")

func _on_back_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://MainMenu.tscn")

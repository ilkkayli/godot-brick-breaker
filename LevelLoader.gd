extends Node
class_name LevelLoader

const BRICK_SCENE = preload("res://Brick.tscn")
const TOP_OFFSET = 80

func load_level(level_number: int, parent: Node) -> int:
	print("=== load_level kutsuttu ===")
	print(get_stack())
	var path = "res://levels/level_%d.txt" % level_number

	if not FileAccess.file_exists(path):
		path = "res://levels/level_1.txt"
		if not FileAccess.file_exists(path):
			print("VIRHE: level_1.txt puuttuu!")
			return 0

	print("Ladataan: ", path)
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("Virhe: ei voida avata tiedostoa")
		return 0

	var lines = []
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line != "":
			lines.append(line)
	file.close()

	print("Rivejä luettu: ", lines.size())
	return _spawn_bricks(lines, parent)

func _spawn_bricks(lines: Array, parent: Node) -> int:
	var breakable_count = 0
	var rows = lines.size()
	var max_cols = 0
	for line in lines:
		if line.length() > max_cols:
			max_cols = line.length()
	var screen_w = 480.0
	var margin = 10.0
	var gap_x = 6.0
	var gap_y = 1.0
	var brick_w = (screen_w - margin * 2 - gap_x * (max_cols - 1)) / max_cols
	var brick_h = brick_w * 1.0
	var start_x = margin + brick_w / 2.0
	for row in range(rows):
		var line = lines[row]
		for col in range(line.length()):
			var ch = line[col]
			if ch == ".":
				continue
			var brick_type = _char_to_type(ch)
			if brick_type == -1:
				continue
			var brick = BRICK_SCENE.instantiate()
			var x = start_x + col * (brick_w + gap_x)
			var y = TOP_OFFSET + row * (brick_h + gap_y)
			brick.position = Vector2(x, y)
			parent.add_child(brick)
			brick.setup(brick_type)
			var sprite = brick.get_node("Sprite2D")
			sprite.scale = Vector2(brick_w / 310.0, brick_h / 200.0)
			var shape = brick.get_node("CollisionShape2D").shape
			shape.size = Vector2(brick_w / 2.0, brick_h / 2.0)
			if brick_type != Brick.Type.UNBREAKABLE:
				breakable_count += 1
	return breakable_count

func _char_to_type(ch: String) -> int:
	match ch:
		"B": return Brick.Type.NORMAL
		"S": return Brick.Type.STRONG
		"U": return Brick.Type.UNBREAKABLE
		"E": return Brick.Type.EXPLOSIVE
	return -1

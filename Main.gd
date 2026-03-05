extends Node2D

const BRICK_SCENE = preload("res://Brick.tscn")

const COLS = 6
const ROWS = 5
const BRICK_WIDTH = 57
const BRICK_HEIGHT = 15
const PADDING = 10
const TOP_OFFSET = 80

var score = 0

func _ready() -> void:
	spawn_bricks()

func spawn_bricks() -> void:
	var total_width = COLS * BRICK_WIDTH + (COLS - 1) * PADDING
	var start_x = (480 - total_width) / 2 + BRICK_WIDTH / 2

	for row in range(ROWS):
		for col in range(COLS):
			var brick = BRICK_SCENE.instantiate()
			var x = start_x + col * (BRICK_WIDTH + PADDING)
			var y = TOP_OFFSET + row * (BRICK_HEIGHT + PADDING)
			brick.position = Vector2(x, y)
			brick.brick_destroyed.connect(_on_brick_destroyed)
			add_child(brick)

func _on_brick_destroyed() -> void:
	score += 10
	print("Score: ", score)

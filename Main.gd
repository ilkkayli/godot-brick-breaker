extends Node2D

const BRICK_SCENE = preload("res://Brick.tscn")

const COLS = 6
const ROWS = 5
const BRICK_WIDTH = 57
const BRICK_HEIGHT = 15
const PADDING = 10
const TOP_OFFSET = 80
const BASE_SPEED = 500.0
const SPEED_INCREMENT = 40.0

var score = 0
var game_over = false
var level = 1
var bricks_remaining = 0

@onready var ball = $Ball
@onready var paddle = $Paddle
@onready var death_zone = $DeathZone
@onready var score_label = $HUD/TopBar/ScoreLabel
@onready var level_label = $HUD/TopBar/LevelLabel

func _ready() -> void:
	spawn_bricks()
	death_zone.body_entered.connect(_on_death_zone_body_entered)
	update_hud()

func update_hud() -> void:
	score_label.text = "Score: " + str(score)
	level_label.text = "Level: " + str(level)

func spawn_bricks() -> void:
	for child in get_children():
		if child is StaticBody2D and child.has_method("hit"):
			child.queue_free()

	bricks_remaining = COLS * ROWS
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
	bricks_remaining -= 1
	update_hud()

	if bricks_remaining <= 0:
		level_clear()

func level_clear() -> void:
	level += 1
	update_hud()
	print("LEVEL CLEAR! Starting level ", level)
	ball.speed = BASE_SPEED + (level - 1) * SPEED_INCREMENT
	ball.position = Vector2(240, 600)
	ball.launch()
	spawn_bricks()

func _on_death_zone_body_entered(body: Node) -> void:
	if body == ball:
		game_over = true
		ball.stop()
		print("GAME OVER | Final score: ", score, " | Level: ", level)

func _input(event: InputEvent) -> void:
	if not game_over:
		return
	if event is InputEventScreenTouch and event.pressed:
		restart()
	elif event is InputEventMouseButton and event.pressed:
		restart()

func restart() -> void:
	game_over = false
	score = 0
	level = 1
	ball.speed = BASE_SPEED
	ball.position = Vector2(240, 600)
	paddle.position = Vector2(240, 780)
	ball.launch()
	spawn_bricks()
	update_hud()

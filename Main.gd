extends Node2D

const BRICK_SCENE = preload("res://Brick.tscn")
const PowerUp = preload("res://PowerUp.gd")

const BASE_SPEED = 500.0
const SPEED_INCREMENT = 40.0
const MAX_LIVES = 3

var score = 0
var game_over = false
var level = 1
var bricks_remaining = 0
var lives = MAX_LIVES
var loader = LevelLoader.new()

@onready var ball = $Ball
@onready var paddle = $Paddle
@onready var death_zone = $DeathZone
@onready var score_label = $HUD/TopBar/ScoreLabel
@onready var level_label = $HUD/TopBar/LevelLabel
@onready var lives_label = $HUD/TopBar/LivesLabel

const SLOW_DURATION: float = 8.0
const SLOW_MULTIPLIER: float = 0.5
var slow_timer: float = 0.0
var is_slowed: bool = false

func _ready() -> void:
	spawn_bricks()
	death_zone.body_entered.connect(_on_death_zone_body_entered)
	update_hud()

func update_hud() -> void:
	score_label.text = "Score: " + str(score)
	level_label.text = "Level: " + str(level)
	lives_label.text = "Lives: " + str(lives)

func spawn_bricks() -> void:
	for child in get_children():
		if child is StaticBody2D and child.has_method("hit"):
			child.queue_free() 
	bricks_remaining = loader.load_level(level, self)
	for child in get_children():
		if child is StaticBody2D and child.has_method("hit"):
			if not child.brick_destroyed.is_connected(_on_brick_destroyed):
				child.brick_destroyed.connect(_on_brick_destroyed)

func respawn_ball() -> void:
	ball.position = Vector2(240, 600)
	ball.speed = BASE_SPEED + (level - 1) * SPEED_INCREMENT
	ball.launch()

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
	respawn_ball()
	call_deferred("spawn_bricks") 

func _on_death_zone_body_entered(body: Node) -> void:
	if not (body is CharacterBody2D and body.has_method("set_speed")):
		return
	body.stop()
	if body != ball:
		body.queue_free()
	await get_tree().process_frame
	var active_balls = 0
	for child in get_children():
		if child is CharacterBody2D and child.has_method("set_speed") and child != ball and child.active:
			active_balls += 1
	if active_balls == 0 and not ball.active:
		lives -= 1
		update_hud()
		if lives > 0:
			print("Lives remaining: ", lives)
			respawn_ball()
		else:
			game_over = true
			print("GAME OVER | Score: ", score, " | Level: ", level)

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
	lives = MAX_LIVES
	is_slowed = false
	for child in get_children():
		if child is CharacterBody2D and child.has_method("set_speed") and child != ball:
			child.queue_free()
	paddle.position = Vector2(240, 780)
	if paddle.powered_up:
		paddle.deactivate_powerup()
	await get_tree().process_frame
	respawn_ball()
	spawn_bricks()
	update_hud()

func _process(delta: float) -> void:
	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0:
			deactivate_slow()

func apply_powerup(type: int) -> void:
	match type:
		PowerUp.Type.EXPAND_PADDLE:
			if not paddle.powered_up:  # ← vain jos ei jo aktiivinen
				paddle.activate_expand()
		PowerUp.Type.MULTIBALL:
			spawn_extra_ball()
		PowerUp.Type.SLOW_BALL:
			activate_slow()
		PowerUp.Type.EXTRA_LIFE:
			if lives < MAX_LIVES:
				lives += 1
				update_hud()
				print("Extra life! Lives: ", lives)
			else:
				print("Max lives already reached")

func spawn_extra_ball() -> void:
	var ball_scene = load("res://Ball.tscn")
	var new_ball = ball_scene.instantiate()
	new_ball.position = Vector2(240, 600)
	new_ball.speed = BASE_SPEED + (level - 1) * SPEED_INCREMENT
	call_deferred("add_child", new_ball)
	print("Multiball!")

func activate_slow() -> void:
	is_slowed = true
	slow_timer = SLOW_DURATION
	_set_all_ball_speeds(BASE_SPEED * SLOW_MULTIPLIER)
	print("Slow Ball!")

func deactivate_slow() -> void:
	is_slowed = false
	_set_all_ball_speeds(BASE_SPEED + (level - 1) * SPEED_INCREMENT)
	print("Slow loppui")

func _set_all_ball_speeds(new_speed: float) -> void:
	for child in get_children():
		if child is CharacterBody2D and child.has_method("set_speed"):
			child.set_speed(new_speed)

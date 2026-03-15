extends Node2D

const BRICK_SCENE = preload("res://Brick.tscn")
const PowerUp = preload("res://PowerUp.gd")
const LevelComplete = preload("res://LevelComplete.gd")
const DailyChallengeResult = preload("res://DailyChallengeResult.gd")

var BASE_SPEED = 500.0
var SPEED_INCREMENT = 40.0
var MAX_LIVES = 3

var score = 0
var game_over = false
var level = 1
var bricks_remaining = 0
var lives = MAX_LIVES
var loader = LevelLoader.new()
var score_multiplier: float = 1.0

@onready var ball = $Ball
@onready var paddle = $Paddle
@onready var death_zone = $DeathZone
@onready var score_label = $HUD/TopBar/ScoreLabel
@onready var level_label = $HUD/TopBar/LevelLabel
@onready var lives_label = $HUD/TopBar/LivesLabel
@onready var snd_paddle_hit = $SndPaddleHit
@onready var snd_brick_break = $SndBrickBreak
@onready var snd_wall_bounce = $SndWallBounce
@onready var snd_powerup = $SndPowerup
@onready var snd_explosion = $SndExplosion
@onready var snd_game_over = $SndGameOver
@onready var menu_button = $HUD/TopBar/MenuButton  
@onready var game_over_screen = $GameOverLayer/GameOver
@onready var music_player = $MusicPlayer
@onready var pause_screen = $PauseLayer/Pause
@onready var pause_button = $HUD/TopBar/PauseButton
@onready var confirm_dialog = $ConfirmLayer/ConfirmDialog
@onready var background = $Background
@onready var multiplier_label = $HUD/MultiplierLabel

const SLOW_DURATION: float = 8.0
const SLOW_MULTIPLIER: float = 0.5
var slow_timer: float = 0.0
var is_slowed: bool = false

func _ready() -> void:
	var font = load("res://assets/fonts/orbitron.ttf")
	multiplier_label.add_theme_font_override("font", font)
	multiplier_label.add_theme_font_size_override("font_size", 16)
	
	var difficulty = SaveManager.get_difficulty()
	var diff = SaveManager.get_difficulty_data()
	var episode = int(SaveManager.get_setting("current_episode", 1))
	score_multiplier = diff["score_multiplier"]
	
	match difficulty:
		"normal": multiplier_label.add_theme_color_override("font_color", Color("#FFD700"))
		"hard":   multiplier_label.add_theme_color_override("font_color", Color("#FF1744"))
	
	print("=== DIFFICULTY DEBUG ===")
	print("Difficulty: ", difficulty)
	print("BASE_SPEED: ", diff["speeds"][episode])
	print("PADDLE_WIDTH: ", 110.0 * diff["paddle_multiplier"])
	print("MAX_LIVES: ", diff["lives"])
	print("Powerup chance: ", diff["powerup_chance"])
	print("========================")
	
	if DailyChallenge.is_active:
		BASE_SPEED = 300.0
		level = 1
		score = 0
	else:
		BASE_SPEED = diff["speeds"][episode]
		level = int(SaveManager.get_setting("current_level", 1))
		score = int(SaveManager.get_setting("current_score", 0))
	
	# Paddle width
	paddle.PADDLE_WIDTH = 110.0 * diff["paddle_multiplier"]
	paddle.apply_width()
	
	# Lives
	MAX_LIVES = diff["lives"]
	lives = MAX_LIVES
	
	# Aseta pallon nopeus heti
	ball.speed = BASE_SPEED
	
	if DailyChallenge.is_active:
		_apply_daily_modifier()
	
	_load_background()
	spawn_bricks()
	death_zone.body_entered.connect(_on_death_zone_body_entered)
	update_hud()
	menu_button.pressed.connect(_on_menu_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	game_over_screen.restart_game.connect(_on_game_over_restart)
	game_over_screen.watch_ad.connect(_on_watch_ad)
	pause_screen.resume_game.connect(_on_resume_pressed)
	pause_screen.go_to_menu.connect(_on_menu_pressed)
	var yes_btn = $ConfirmLayer/ConfirmDialog/PanelContainer/VBoxContainer/HBoxContainer/YesButton
	var no_btn = $ConfirmLayer/ConfirmDialog/PanelContainer/VBoxContainer/HBoxContainer/NoButton
	yes_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	no_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	yes_btn.pressed.connect(_on_confirm_yes)
	no_btn.pressed.connect(_on_confirm_no)
	confirm_dialog.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_menu_pressed() -> void:
	get_tree().paused = true
	confirm_dialog.visible = true
	
func _on_confirm_yes() -> void:
	confirm_dialog.visible = false
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://MainMenu.tscn")

func _on_confirm_no() -> void:
	confirm_dialog.visible = false
	get_tree().paused = false

func update_hud() -> void:
	score_label.text = "Score: " + str(score)
	level_label.text = "Level: " + str(level)
	lives_label.text = "Lives: " + str(lives)
	var diff = SaveManager.get_difficulty()
	match diff:
		"normal": multiplier_label.text = "Bonus x1.5"
		"hard":   multiplier_label.text = "Bonus x2"
		_:        multiplier_label.text = ""

func spawn_bricks() -> void:
	bricks_destroyed_count = 0
	for child in get_children():
		if child is StaticBody2D and child.has_method("hit"):
			child.queue_free()
	
	if DailyChallenge.is_active:
		bricks_remaining = _spawn_daily_bricks()
	else:
		var episode = SaveManager.get_setting("current_episode", 1)
		bricks_remaining = loader.load_level(episode, level, self)
	
	for child in get_children():
		if child is StaticBody2D and child.has_method("hit"):
			if not child.brick_destroyed.is_connected(_on_brick_destroyed):
				child.brick_destroyed.connect(_on_brick_destroyed)

func respawn_ball() -> void:
	ball.speed = BASE_SPEED + (level - 1) * SPEED_INCREMENT
	ball.attach_to_paddle(paddle)

var bricks_destroyed_count: int = 0

func _on_brick_destroyed() -> void:
	score += int(10 * score_multiplier)
	bricks_remaining -= 1
	bricks_destroyed_count += 1
	
	# Speed boost joka 10. tiilestä
	if bricks_destroyed_count % 10 == 0:
		for b in get_tree().get_nodes_in_group("balls"):
			b.speed += 5
			b.velocity = b.velocity.normalized() * b.speed
	
	update_hud()
	if bricks_remaining <= 0:
		level_clear()

func level_clear() -> void:
	if DailyChallenge.is_active:
		DailyChallengeResult.final_score = score
		DailyChallenge.is_active = false
		ball.stop()
		get_tree().call_deferred("change_scene_to_file", "res://DailyChallengeResult.tscn")
		return
		
	var episode = SaveManager.get_setting("current_episode", 1)
	var episode_levels = SaveManager.get_episode_level_count(episode)
	
	SaveManager.update_highest_level(episode, level)
	
	if level >= episode_levels:
		# Episodi läpäisty
		LevelComplete.current_level = level
		LevelComplete.current_score = score
		LevelComplete.episode_complete = true
		LevelComplete.current_episode = episode
		ball.stop()
		SaveManager.set_setting("current_score", score)
		get_tree().call_deferred("change_scene_to_file", "res://LevelComplete.tscn")
	else:
		# Seuraava level samassa episodissa
		level += 1
		update_hud()
		ball.stop()
		LevelComplete.current_level = level
		LevelComplete.current_score = score
		LevelComplete.episode_complete = false
		LevelComplete.current_episode = episode
		SaveManager.set_setting("current_level", level)
		SaveManager.set_setting("current_score", score)
		get_tree().call_deferred("change_scene_to_file", "res://LevelComplete.tscn")

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
			if DailyChallenge.is_active:
				print("DailyChallenge.is_active: ", DailyChallenge.is_active)
				DailyChallengeResult.final_score = score
				DailyChallenge.is_active = false
				get_tree().call_deferred("change_scene_to_file", "res://DailyChallengeResult.tscn")
			else:
				game_over = true
				save_high_score()
				snd_game_over.play()
				game_over_screen.setup(score, load_high_score())
				game_over_screen.visible = true
				print("GAME OVER | Score: ", score, " | Level: ", level)

func _input(event: InputEvent) -> void:
	if ball.attached:
		if event is InputEventScreenTouch and event.pressed:
			ball.launch()
			return
		elif event is InputEventMouseButton and event.pressed:
			ball.launch()
			return

func restart() -> void:
	game_over = false
	score = 0
	level = 1
	lives = MAX_LIVES
	is_slowed = false
	SaveManager.set_setting("current_level", 1)
	SaveManager.set_setting("current_score", 0)
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
	# Pallo seuraa paddlea kun kiinnitetty
	if ball.attached:
		ball.position = Vector2(paddle.position.x, paddle.position.y - 25)

	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0:
			deactivate_slow()

func apply_powerup(type: int) -> void:
	snd_powerup.play()
	match type:
		PowerUp.Type.EXPAND_PADDLE:
			if not paddle.powered_up:
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
		PowerUp.Type.REVERSE_BALL:
			reverse_all_balls()

func reverse_all_balls() -> void:
	for child in get_children():
		if child is CharacterBody2D and child.has_method("reverse"):
			child.reverse()
	print("Reverse Ball!")

func spawn_extra_ball() -> void:
	var ball_scene = load("res://Ball.tscn")
	var new_ball = ball_scene.instantiate()
	new_ball.position = Vector2(paddle.position.x, paddle.position.y - 25)
	new_ball.speed = BASE_SPEED + (level - 1) * SPEED_INCREMENT
	add_child(new_ball)
	new_ball.launch()  # ← käynnistä heti
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
			
func save_high_score() -> void:
	var current_best = load_high_score()
	if score > current_best:
		var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
		file.store_32(score)
		file.close()

func load_high_score() -> int:
	if FileAccess.file_exists("user://save.dat"):
		var file = FileAccess.open("user://save.dat", FileAccess.READ)
		var s = file.get_32()
		file.close()
		return s
	return 0
	
func _on_game_over_restart() -> void:
	game_over_screen.visible = false
	restart()

func _on_watch_ad() -> void:
	# Rewarded ad logiikka tulee tähän myöhemmin
	game_over_screen.visible = false
	lives = 1
	game_over = false
	respawn_ball()
	update_hud()
	
func _on_music_finished() -> void:
	music_player.play()

func _on_pause_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_button.text = "⏸"
	else:
		get_tree().paused = true
		pause_button.text = "▶"

func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_screen.visible = false
	
func _load_background() -> void:
	var episode = SaveManager.get_setting("current_episode", 1)
	var path = "res://assets/backgrounds/bg_episode_%d.png" % episode
	if ResourceLoader.exists(path):
		background.texture = load(path)
		background.scale = Vector2(480.0 / 1024.0, 854.0 / 1536.0)
		background.position = Vector2(240, 427)
	else:
		print("Taustakuvaa ei löydy: ", path)
		
func _spawn_daily_bricks() -> int:
	var grid = DailyChallenge.generate_level()
	var breakable = 0
	var cols = grid[0].size()
	var rows = grid.size()
	var screen_w = 480.0
	var margin = 10.0
	var gap_x = 6.0
	var gap_y = 1.0
	var brick_w = (screen_w - margin * 2 - gap_x * (cols - 1)) / cols
	var brick_h = brick_w
	var start_x = margin + brick_w / 2.0
	
	for r in range(rows):
		for c in range(cols):
			var ch = grid[r][c]
			if ch == ".":
				continue
			var brick_type = _char_to_brick_type(ch)
			var brick = BRICK_SCENE.instantiate()
			brick.position = Vector2(start_x + c * (brick_w + gap_x), 80 + r * (brick_h + gap_y))
			add_child(brick)
			brick.setup(brick_type)
			brick.get_node("Sprite2D").scale = Vector2(brick_w / 310.0, brick_h / 200.0)
			brick.get_node("CollisionShape2D").shape.size = Vector2(brick_w / 2.0, brick_h / 2.0)
			if brick_type != Brick.Type.UNBREAKABLE:
				breakable += 1
	return breakable
	
func _char_to_brick_type(ch: String) -> int:
	match ch:
		"B": return Brick.Type.NORMAL
		"S": return Brick.Type.STRONG
		"E": return Brick.Type.EXPLOSIVE
		"U": return Brick.Type.UNBREAKABLE
	return Brick.Type.NORMAL

func _apply_daily_modifier() -> void:
	var key = DailyChallenge.modifier["key"]
	match key:
		"fast_ball":
			BASE_SPEED *= 1.5
			ball.speed = BASE_SPEED
		"small_paddle":
			paddle.PADDLE_WIDTH *= 0.5
			paddle.apply_width()
		"extra_powerups":
			pass  # Hoidetaan Brick.gd:ssä
		"multiball_start":
			spawn_extra_ball()
			spawn_extra_ball()

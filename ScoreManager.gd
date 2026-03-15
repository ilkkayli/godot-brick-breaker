extends Node

# Current state
var score: int = 0
var combo: int = 0
var multiplier: int = 1
var chain_active: bool = false
var bricks_remaining: int = 0
var level_timer: float = 0.0
var timer_running: bool = false

# Signals
signal score_changed(new_score: int)
signal combo_changed(new_combo: int)

func reset() -> void:
	score = 0
	combo = 0
	multiplier = 1
	chain_active = false
	level_timer = 0.0
	timer_running = true

func _process(delta: float) -> void:
	if timer_running:
		level_timer += delta

func brick_destroyed(is_last_brick: bool = false) -> void:
	combo += 1
	multiplier = _get_multiplier(combo)
	
	var points = 10 * multiplier
	score += points
	
	print("Brick destroyed | Combo: %d | Multiplier: x%d | Points: +%d | Total: %d" % [combo, multiplier, points, score])
	
	if is_last_brick and combo > 0:
		score += 500
		print("LAST BRICK BONUS! +500 | Total: %d" % score)
	
	score_changed.emit(score)
	combo_changed.emit(combo)

func paddle_hit() -> void:
	if combo > 0:
		print("Paddle hit — combo reset from %d" % combo)
	combo = 0
	multiplier = 1
	combo_changed.emit(combo)

func explosion_chain() -> void:
	score += 50
	print("Chain explosion bonus! +50 | Total: %d" % score)
	score_changed.emit(score)

func level_completed() -> void:
	timer_running = false
	var max_time = 120.0
	var remaining = max(0.0, max_time - level_timer)
	var time_bonus = int(remaining * 10)
	score += time_bonus
	print("Level complete! Time: %.1fs | Remaining: %.1fs | Time bonus: +%d | Total: %d" % [level_timer, remaining, time_bonus, score])
	score_changed.emit(score)

func _get_multiplier(current_combo: int) -> int:
	if current_combo >= 5:
		return 5
	elif current_combo >= 3:
		return 3
	elif current_combo >= 2:
		return 2
	return 1

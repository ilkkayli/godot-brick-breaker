extends CharacterBody2D

const PADDLE_WIDTH: float = 200.0
const PADDLE_WIDTH_POWERED: float = 320.0
const POWERUP_DURATION: float = 10.0

var screen_width: float = 0.0
var target_x: float = 0.0
var touch_index: int = -1
var powered_up: bool = false
var powerup_timer: float = 0.0

func _ready() -> void:
	screen_width = get_viewport_rect().size.x
	target_x = global_position.x

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_index = event.index
			target_x = _clamped(event.position.x)
		elif event.index == touch_index:
			touch_index = -1
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			target_x = _clamped(event.position.x)
	elif event is InputEventMouseMotion:
		target_x = _clamped(event.position.x)

func _physics_process(delta: float) -> void:
	if powered_up:
		powerup_timer -= delta
		if powerup_timer <= 0:
			deactivate_powerup()

	velocity.x = (target_x - global_position.x) / delta
	velocity.y = 0
	move_and_slide()

func _clamped(x: float) -> float:
	var half = get_current_width() / 2.0
	return clamp(x, half, screen_width - half)

func get_current_width() -> float:
	return PADDLE_WIDTH_POWERED if powered_up else PADDLE_WIDTH

func collect_powerup() -> void:
	powered_up = true
	powerup_timer = POWERUP_DURATION
	_update_collision_shape()
	print("Power-up! Paddle laajenee 10 sekunniksi")

func deactivate_powerup() -> void:
	powered_up = false
	powerup_timer = 0.0
	_update_collision_shape()
	print("Power-up loppui")

func _update_collision_shape() -> void:
	var shape = $CollisionShape2D.shape
	shape.size.x = get_current_width() / 2.0
	var color_rect = $ColorRect
	color_rect.size.x = get_current_width()
	color_rect.position.x = -get_current_width() / 2.0

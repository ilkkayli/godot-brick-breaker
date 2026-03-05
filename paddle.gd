extends CharacterBody2D

const PADDLE_WIDTH: float = 200.0

var screen_width: float = 0.0
var target_x: float = 0.0
var touch_index: int = -1

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
	velocity.x = (target_x - global_position.x) / delta
	velocity.y = 0
	move_and_slide()

func _clamped(x: float) -> float:
	var half = PADDLE_WIDTH / 2.0
	return clamp(x, half, screen_width - half)

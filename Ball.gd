extends CharacterBody2D

const RADIUS: float = 15.0

var active: bool = true
var speed: float = 500.0

func _ready() -> void:
	add_to_group("balls")
	launch()

func launch() -> void:
	active = true
	var angle = deg_to_rad(randf_range(-60, 60))
	velocity = Vector2(sin(angle), -cos(angle)).normalized() * speed

func stop() -> void:
	active = false
	velocity = Vector2.ZERO

func set_speed(new_speed: float) -> void:
	speed = new_speed
	if active and velocity.length() > 0:
		velocity = velocity.normalized() * speed

func _physics_process(delta: float) -> void:
	if not active:
		return
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		var collider = collision.get_collider()
		if collider.has_method("hit"):
			collider.hit()

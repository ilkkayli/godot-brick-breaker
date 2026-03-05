extends CharacterBody2D

const SPEED: float = 500.0
const RADIUS: float = 15.0

func _ready() -> void:
	var angle = deg_to_rad(randf_range(-60, 60))
	velocity = Vector2(sin(angle), -cos(angle)).normalized() * SPEED

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		var collider = collision.get_collider()
		if collider.has_method("hit"):
			collider.hit()

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color.WHITE)

extends CharacterBody2D

const RADIUS: float = 15.0

var active: bool = false
var speed: float = 500.0
var attached: bool = true

func _ready() -> void:
	add_to_group("balls")

func launch() -> void:
	active = true
	attached = false
	var angle = deg_to_rad(randf_range(-60, 60))
	velocity = Vector2(sin(angle), -cos(angle)).normalized() * speed

func stop() -> void:
	active = false
	attached = false
	velocity = Vector2.ZERO

func attach_to_paddle(paddle: Node) -> void:
	attached = true
	active = false
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if attached:
		return
	if not active:
		return
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		var collider = collision.get_collider()
		if collider.has_method("hit"):
			collider.hit()

func reverse() -> void:
	velocity = -velocity

func set_speed(new_speed: float) -> void:
	speed = new_speed
	if active and velocity.length() > 0:
		velocity = velocity.normalized() * speed

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color.WHITE)

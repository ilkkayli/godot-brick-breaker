extends Area2D

const FALL_SPEED: float = 150.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > 1000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("collect_powerup"):
		body.collect_powerup()
		queue_free()

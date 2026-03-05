extends Area2D

enum Type { EXPAND_PADDLE, MULTIBALL, SLOW_BALL, EXTRA_LIFE }

const FALL_SPEED: float = 150.0
const COLORS = {
	Type.EXPAND_PADDLE: Color.YELLOW,
	Type.MULTIBALL: Color.CYAN,
	Type.SLOW_BALL: Color.GREEN,
	Type.EXTRA_LIFE: Color.RED
}

var type: Type = Type.EXPAND_PADDLE

func _ready() -> void:
	$ColorRect.color = COLORS[type]
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > 1000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("collect_powerup"):
		body.collect_powerup(type)
		queue_free()

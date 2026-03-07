extends Area2D

enum Type { EXPAND_PADDLE, MULTIBALL, SLOW_BALL, EXTRA_LIFE, REVERSE_BALL }

const FALL_SPEED: float = 150.0
const SPRITESHEET = preload("res://spritesheet.png")

const REGIONS = {
	Type.EXPAND_PADDLE: Rect2(808, 129, 280, 200),
	Type.MULTIBALL:     Rect2(1103, 120, 280, 200),
	Type.SLOW_BALL:     Rect2(152, 344, 280, 200),
	Type.EXTRA_LIFE:    Rect2(477, 345, 280, 200),
	Type.REVERSE_BALL:  Rect2(130, 749, 280, 200)  
}

var type: Type = Type.EXPAND_PADDLE

func _ready() -> void:
	_update_sprite()
	body_entered.connect(_on_body_entered)

func _update_sprite() -> void:
	var sprite = $Sprite2D
	var atlas = AtlasTexture.new()
	atlas.atlas = SPRITESHEET
	atlas.region = REGIONS[type]
	sprite.texture = atlas
	sprite.scale = Vector2(40.0 / 280.0, 40.0 / 280.0)

func _physics_process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > 1000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("collect_powerup"):
		body.collect_powerup(type)
		queue_free()

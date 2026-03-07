extends StaticBody2D
class_name Brick

signal brick_destroyed

const POWERUP_SCENE = preload("res://PowerUp.tscn")
const PowerUp = preload("res://PowerUp.gd")
const SPRITESHEET = preload("res://spritesheet.png")
const POWERUP_CHANCE = 0.2

enum Type { NORMAL, STRONG, UNBREAKABLE, EXPLOSIVE }

# Region-arvot jokaiselle tiilityypille
const REGIONS = {
	Type.NORMAL:      Rect2(788, 351, 310, 200),
	Type.STRONG:      Rect2(785, 578, 310, 200),
	Type.UNBREAKABLE: Rect2(465, 576, 310, 200),
	Type.EXPLOSIVE:   Rect2(136, 577, 310, 200)
}
const DAMAGED_REGION = Rect2(1096, 351, 310, 200)

var health: int = 1
var type: Type = Type.NORMAL
var is_destroyed: bool = false

func setup(new_type: Type) -> void:
	type = new_type
	match type:
		Type.NORMAL:      health = 1
		Type.STRONG:      health = 2
		Type.UNBREAKABLE: health = -1
		Type.EXPLOSIVE:   health = 1
	_update_sprite()

func _update_sprite() -> void:
	var sprite = $Sprite2D
	var atlas = AtlasTexture.new()
	atlas.atlas = SPRITESHEET
	if type == Type.STRONG and health == 1:
		atlas.region = DAMAGED_REGION
	else:
		atlas.region = REGIONS[type]
	sprite.texture = atlas

func hit() -> void:
	if type == Type.UNBREAKABLE:
		return
	if is_destroyed:
		return
	health -= 1
	if health <= 0:
		is_destroyed = true
		_on_destroyed()
	else:
		_update_sprite()

func _on_destroyed() -> void:
	if type == Type.EXPLOSIVE:
		_explode()
	if randf() < POWERUP_CHANCE:
		var powerup = POWERUP_SCENE.instantiate()
		powerup.position = global_position
		var types = PowerUp.Type.values()
		powerup.type = types[randi() % types.size()]
		get_parent().add_child(powerup)
	brick_destroyed.emit()
	queue_free()

func _explode() -> void:
	var neighbors = [
		Vector2(0, -1), Vector2(0, 1),
		Vector2(-1, 0), Vector2(1, 0)
	]
	var brick_size = Vector2(57 + 10, 15 + 10)
	for dir in neighbors:
		var target_pos = global_position + dir * brick_size
		for child in get_parent().get_children():
			if child == self:
				continue
			if child is StaticBody2D and child.has_method("hit"):
				if child.global_position.distance_to(target_pos) < 10:
					child.hit()

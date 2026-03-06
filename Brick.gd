extends StaticBody2D
class_name Brick

signal brick_destroyed

const POWERUP_SCENE = preload("res://PowerUp.tscn")
const PowerUp = preload("res://PowerUp.gd")
const POWERUP_CHANCE = 0.2

enum Type { NORMAL, STRONG, UNBREAKABLE, EXPLOSIVE }

const COLORS = {
	Type.NORMAL:      Color(0.2, 0.6, 1.0),   # sininen
	Type.STRONG:      Color(1.0, 0.4, 0.0),   # oranssi
	Type.UNBREAKABLE: Color(0.4, 0.4, 0.4),   # harmaa
	Type.EXPLOSIVE:   Color(0.8, 0.0, 0.8)    # violetti
}
const DAMAGED_COLOR = Color(0.8, 0.2, 0.2)   # punainen – vahva tiili vaurioitunut

var health: int = 1
var type: Type = Type.NORMAL
var is_destroyed: bool = false

func setup(new_type: Type) -> void:
	type = new_type
	match type:
		Type.NORMAL:
			health = 1
		Type.STRONG:
			health = 2
		Type.UNBREAKABLE:
			health = -1  # ei koskaan nolla
		Type.EXPLOSIVE:
			health = 1
	_update_color()

func _update_color() -> void:
	var cr = $ColorRect
	if type == Type.STRONG and health == 1:
		cr.color = DAMAGED_COLOR
	else:
		cr.color = COLORS[type]

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
		_update_color()

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
		Vector2(0, -1),  # ylös
		Vector2(0,  1),  # alas
		Vector2(-1, 0),  # vasemmalle
		Vector2(1,  0)   # oikealle
	]
	var brick_size = Vector2(57 + 10, 15 + 10)  # BRICK_WIDTH + PADDING
	for dir in neighbors:
		var target_pos = global_position + dir * brick_size
		for child in get_parent().get_children():
			if child == self:
				continue
			if child is StaticBody2D and child.has_method("hit"):
				if child.global_position.distance_to(target_pos) < 10:
					child.hit()

extends StaticBody2D
class_name Brick

signal brick_destroyed

const POWERUP_SCENE = preload("res://PowerUp.tscn")
const PowerUp = preload("res://PowerUp.gd")
const SPRITESHEET = preload("res://spritesheet.png")
const PARTICLES_SCENE = preload("res://BrickParticles.tscn")
const POWERUP_CHANCE = 0.2

enum Type { NORMAL, STRONG, UNBREAKABLE, EXPLOSIVE }

const REGIONS = {
	Type.NORMAL:      Rect2(788, 351, 310, 200),
	Type.STRONG:      Rect2(785, 578, 310, 200),
	Type.UNBREAKABLE: Rect2(465, 576, 310, 200),
	Type.EXPLOSIVE:   Rect2(136, 577, 310, 170)
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
	_spawn_particles()
	var main = get_tree().get_first_node_in_group("main")
	if type == Type.EXPLOSIVE:
		main.snd_explosion.play()
		_explode()
	else:
		main.snd_brick_break.play()
	var chance = SaveManager.get_difficulty_data()["powerup_chance"]
	if randf() < chance:
		var powerup = POWERUP_SCENE.instantiate()
		powerup.position = global_position
		var types = PowerUp.Type.values()
		powerup.type = types[randi() % types.size()]
		get_parent().add_child(powerup)
	brick_destroyed.emit()
	queue_free()

func _spawn_particles() -> void:
	var particles = PARTICLES_SCENE.instantiate()
	particles.position = global_position
	get_parent().add_child(particles)

	match type:
		Type.NORMAL:
			particles.amount = 12
			particles.process_material.initial_velocity_min = 50
			particles.process_material.initial_velocity_max = 150
			particles.process_material.color = Color(0.2, 0.6, 1.0)  # sininen
		Type.STRONG:
			particles.amount = 20
			particles.process_material.initial_velocity_min = 100
			particles.process_material.initial_velocity_max = 250
			particles.process_material.color = Color(1.0, 0.4, 0.0)  # oranssi
		Type.EXPLOSIVE:
			particles.amount = 35
			particles.process_material.initial_velocity_min = 150
			particles.process_material.initial_velocity_max = 400
			particles.process_material.color = Color(1.0, 0.6, 0.0)  # räjähdys
			_screen_shake()

	particles.emitting = true
	# Poista automaattisesti kun efekti loppuu
	await particles.finished
	particles.queue_free()

func _screen_shake() -> void:
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake"):
		camera.shake(0.3, 8.0)

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
					

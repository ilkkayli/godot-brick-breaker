extends StaticBody2D

signal brick_destroyed

const POWERUP_SCENE = preload("res://PowerUp.tscn")
const POWERUP_CHANCE = 0.2

func hit() -> void:
	if randf() < POWERUP_CHANCE:
		var powerup = POWERUP_SCENE.instantiate()
		powerup.position = global_position
		get_parent().add_child(powerup)
	brick_destroyed.emit()
	queue_free()

extends Camera2D
class_name CameraShake

var shake_duration: float = 0.0
var shake_strength: float = 0.0

func _process(delta: float) -> void:
	if shake_duration > 0:
		shake_duration -= delta
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO

func shake(duration: float, strength: float) -> void:
	shake_duration = duration
	shake_strength = strength

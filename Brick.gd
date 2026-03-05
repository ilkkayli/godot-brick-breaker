extends StaticBody2D

signal brick_destroyed

func hit() -> void:
	brick_destroyed.emit()
	queue_free()

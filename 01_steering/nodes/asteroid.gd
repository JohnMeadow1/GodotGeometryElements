extends AnimatedSprite2D

func _ready() -> void:
	rotation = randf() * TAU
	
	var point: Vector3 = Vector3.ZERO

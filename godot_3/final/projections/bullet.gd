extends Node2D

var velocity = Vector2()
var vector_to_stone = Vector2( 0.0, 0.0 )
onready var stone   = get_node("../stone")

var timer = 0

func _process(delta):
	vector_to_stone = stone.position - self.position
	var gravity = 10000 / max(2500, vector_to_stone.length_squared())
	var gravity_vector = vector_to_stone.normalized() * gravity
	velocity += gravity_vector
	position += velocity
	
#	if timer > 0 :
#		timer-= delta
#		if timer < 0:
#			queue_free()
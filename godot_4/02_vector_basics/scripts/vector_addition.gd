extends "res://scripts/common_functions.gd"

var vector_sum  = Vector2()

func _ready():
	pass

func _process(delta):
	vector_sum = vector1.get_actual_vector() + vector2.get_actual_vector()
	queue_redraw()

func _draw():
	draw_vector( Vector2( ), vector_sum, Color(1,1,1,0.5), 3 )

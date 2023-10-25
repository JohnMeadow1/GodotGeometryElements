extends "res://scripts/common_functions.gd"

var projection_new = Vector2()

func _ready():
	pass

func _process(delta):
	queue_redraw()

func _draw():
	var v1 = vector1.get_actual_vector()
	var v2 = vector2.get_actual_vector()
	projection_new = projection(v1, v2)
	draw_vector( Vector2( 0, 0 ), v1, Color(1,0,0,0.5), 3 )
	draw_vector( Vector2( 0, 0 ), v2, Color(0,1,0,0.5), 3 )
	draw_vector( Vector2( 0, 0 ), projection_new, Color(1,1,0), 2 )
	draw_vector( Vector2( 0, 0 ), v2 - projection_new, Color(1,1,0), 2 )	

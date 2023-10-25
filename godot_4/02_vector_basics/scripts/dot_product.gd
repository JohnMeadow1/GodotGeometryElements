extends "res://scripts/common_functions.gd"

var dot_product = 0

func _ready():
	pass

func _process(delta):
	dot_product = vector1.get_actual_vector().dot(vector2.get_actual_vector())
	queue_redraw()

func _draw():
	var v1 = vector1.get_actual_vector()
	var v2 = vector2.get_actual_vector()
	draw_vector( Vector2( 0, 0 ), v1, Color(1,0,0,0.5), 3 )
	draw_vector( Vector2( 0, 0 ), v2, Color(0,1,0,0.5), 3 )
	$label_position/angle.text = str("%4.3f" % (v1.normalized().dot(v2.normalized())))
	$label_position.position = ( v1.normalized() + v2.normalized() ) * 25
	draw_arc_poly(Vector2( 0, 0 ), 40, v1.angle(), v1.angle_to(v2), Color(1, 1, 0, 0.3))

	

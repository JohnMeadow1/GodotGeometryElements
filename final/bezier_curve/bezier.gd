tool
extends Node2D

var A = Vector2(0.0, 0.0)
var B = Vector2(0.0, 0.0)
var C = Vector2(0.0, 0.0)

var cA = Vector2(0.0, 0.0)
var cB = Vector2(0.0, 0.0)

var colorA = Color(1.0, 0.5, 0.5)
var colorB = Color(0.5, 0.5, 1.0)

var selectionDistance = 10
var pressed           = false
var selection         = null
var offset            = Vector2()

var points = []
var STEPS  = 200
var show_t   = 0

func _ready():
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	show_t += 1
	show_t %= STEPS
	update()

func _input(event):
	if !(get_tree().is_editor_hint()):
		if event.type == InputEvent.MOUSE_MOTION:
			if pressed:
				if selection != null:
					selection.set_pos(event.pos)
			else:
				selection = null
				for point in get_children():
					if event.pos.distance_to(point.get_pos()) < selectionDistance:
						selection = point
		if event.type == InputEvent.MOUSE_BUTTON:
			if event.pressed:
				pressed = true
				selection = null
				for point in get_children():
					if event.pos.distance_to(point.get_pos()) < selectionDistance:
						selection = point
			else:
				pressed   = false
				selection = null

func _draw():
	draw_nodes()
	draw_t()
	if !(get_tree().is_editor_hint()):
		draw_bezier_1()
		draw_bezier_2()
		draw_bezier_3()

	if selection != null:
		draw_circle(selection.get_pos(), 20, Color(1, 1, 1, 0.3))

func get_bezier_1(step, A, B ):
	var t = float(step) / STEPS
	return (1 - t) * A + t * B

func get_bezier_2(step, A, B, C):
	var t = float(step) / STEPS
	var t_1 = 1 - t
	return pow(t_1,2) * A + 2 * t * t_1 * B + pow(t,2) * C

func get_bezier_3(step, A, cA, B, cB):
	var t = float(step) / STEPS
	var t_1 = 1-t
	return pow( t_1, 3 ) * A + 3 * t * pow( t_1, 2 ) * cA + 3 * pow( t, 2 ) * t_1 * cB + pow( t, 3 ) * B

func draw_bezier_1():
	A  = get_child(0).get_pos()
	B  = get_child(1).get_pos()
	
	draw_line(A, B, Color(1,1,0), 1)
	draw_circle(get_bezier_1( show_t, A, B ), 5, Color(0,1,0))

func draw_bezier_2():
	A = get_child(2).get_pos()
	B = get_child(3).get_pos()
	C = get_child(4).get_pos()
	points = []

	var point = Vector2()
	for step in range( STEPS + 1 ):
		point = get_bezier_2( step, A, B, C )
		points.push_back(point)

	for p in range(STEPS):
		draw_line(points[p], points[p+1], Color(1,1,0), 1)
	draw_circle(get_bezier_2( show_t, A, B, C ), 5, Color(0,1,0))

	draw_line( A, B, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( B, C, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line(   get_bezier_1( show_t, A, B ), get_bezier_1(show_t, B, C ), Color( 1, 1, 1, 0.5 ), 1 )
	draw_circle( get_bezier_1( show_t, A, B ), 5, Color(0,1,0,0.5) )
	draw_circle( get_bezier_1( show_t, B, C ), 5, Color(0,1,0,0.5) )

func draw_bezier_3():
	A  = get_child(5).get_pos()
	cA = get_child(6).get_pos()
	B  = get_child(8).get_pos()
	cB = get_child(7).get_pos()
	points = []
	var point = Vector2()
	for step in range( STEPS + 1 ):
		point = get_bezier_3( step, A, cA, B, cB)
		points.push_back(point)

	for p in range( STEPS ):
		draw_line( points[p], points[p+1], Color(1, 1, 0), 1 )

	draw_circle( get_bezier_3( show_t, A, cA, B, cB ), 5, Color(0,1,0) )

	draw_line(  A, cA, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( cA, cB, Color( 1, 1, 1, 0.5 ), 1 )

	draw_line( cB,  B, Color( 1, 1, 1, 0.5 ), 1 )
	var A_cA  = get_bezier_1( show_t, A, cA )
	var cA_cB = get_bezier_1( show_t, cA, cB )
	var cB_B  = get_bezier_1( show_t, cB, B )
	var P_1   = get_bezier_1( show_t, A_cA, cA_cB )
	var P_2   = get_bezier_1( show_t, cA_cB, cB_B )
	draw_line(   A_cA , cA_cB, Color( 1, 1, 1, 0.3 ), 1 )
	draw_line(   cA_cB, cB_B , Color( 1, 1, 1, 0.3 ), 1 )
	draw_line(   P_1  , P_2  , Color( 1, 1, 1, 0.5 ), 1 )
	draw_circle( A_cA,  3, Color( 0, 1, 0, 0.5 ) )
	draw_circle( cA_cB, 3, Color( 0, 1, 0, 0.5 ) )
	draw_circle( cB_B,  3, Color( 0, 1, 0, 0.5 ) )
	draw_circle( P_1,   3, Color( 0, 1, 0, 0.5 ) )
	draw_circle( P_2,   3, Color( 0, 1, 0, 0.5 ) )

func draw_t():
	draw_line( Vector2(100, 50),  Vector2(100, 60),   Color( 1, 1, 1, 0.5 ), 3)
	draw_line( Vector2(100 + STEPS, 50), Vector2(100 + STEPS, 60),  Color( 1, 1, 1, 0.5 ),3)
	draw_line( Vector2(100, 55),  Vector2(100 + STEPS, 55),  Color( 1, 1, 1, 0.5 ) ,1)
	draw_line( Vector2(100 + show_t , 50), Vector2(100 + show_t, 60),  Color( 0, 1, 0 ) ,3)
	get_node("../Label_t").set_pos(Vector2(97 + show_t , 30))
	get_node("../t0").set_pos(Vector2(85, 49))
	get_node("../t1").set_pos(Vector2(105 + STEPS , 49))
	
func draw_nodes():
	for point in get_children():
		draw_circle(point.get_pos(), 7, colorA)
	
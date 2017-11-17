#tool              # only necessary to run script while in editor
extends Node2D

var selectionDistance = 10
var pressed           = false
var selection         = null

var points = []
var STEPS  = 200

var show_t = 0   # parameter used for visualization with green points

func _ready():
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	show_t += 1
	show_t %= STEPS
	update()    # re-draws canvas by calling _draw() function

func _input(event):
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
	draw_bezier_1()
	draw_bezier_2()
	draw_bezier_3()

	if selection != null: # draw selected point
		draw_circle( selection.get_pos(), 20, Color( 1, 1, 1, 0.3 ) )

func get_bezier_1(step, A, B ):
	return Vector2()

func get_bezier_2(step, A, B, C):
	return Vector2()

func get_bezier_3(step, A, cA, B, cB):
	return Vector2()

func draw_bezier_1():
	var A  = get_child(0).get_pos()
	var B  = get_child(1).get_pos()

	draw_line( A, B, Color( 1, 1, 0 ), 1 )

func draw_bezier_2():
	var A = get_child(2).get_pos()
	var B = get_child(3).get_pos()
	var C = get_child(4).get_pos()
	points = []

	var point = Vector2()
	for step in range( STEPS + 1 ):
		point = get_bezier_2( step, A, B, C )
		points.push_back( point )

	for p in range( STEPS ):
		draw_line( points[p], points[p+1], Color( 1, 1, 0 ), 1 )
	draw_circle( get_bezier_2( show_t, A, B, C ), 5, Color( 0, 1, 0 ) )

	# draw support lines and circles
	draw_line( A, B, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( B, C, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line(   get_bezier_1( show_t, A, B ), get_bezier_1(show_t, B, C ), Color( 1, 1, 1, 0.5 ), 1 )
	draw_circle( get_bezier_1( show_t, A, B ), 5, Color( 0, 1, 0, 0.5 ) )
	draw_circle( get_bezier_1( show_t, B, C ), 5, Color( 0, 1, 0, 0.5 ) )

func draw_bezier_3():
	var A  = get_child(5).get_pos()
	var cA = get_child(6).get_pos()
	var cB = get_child(7).get_pos()
	var B  = get_child(8).get_pos()

	points = []
	var point = Vector2()
	for step in range( STEPS + 1 ):
		point = get_bezier_3( step, A, cA, B, cB )
		points.push_back( point )

	for p in range( STEPS ):
		draw_line( points[p], points[p+1], Color(1, 1, 0), 1 )

	draw_circle( get_bezier_3( show_t, A, cA, B, cB ), 5, Color(0,1,0) )

	# draw control lines
	draw_line(  A, cA, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( cB, cA, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( cB,  B, Color( 1, 1, 1, 0.5 ), 1 )

func draw_t():
	draw_line( Vector2(100         , 50), Vector2(100, 60)         , Color( 1, 1, 1, 0.5 ), 3 )
	draw_line( Vector2(100 + STEPS , 50), Vector2(100 + STEPS, 60) , Color( 1, 1, 1, 0.5 ), 3 )
	draw_line( Vector2(100         , 55), Vector2(100 + STEPS, 55) , Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( Vector2(100 + show_t, 50), Vector2(100 + show_t, 60), Color( 0, 1, 0, 1.0 ), 3 )
	get_node("../Label_t" ).set_pos( Vector2( 97 + show_t, 30 ) )
	get_node("../Label_t0").set_pos( Vector2( 85         , 49 ) )
	get_node("../Label_t1").set_pos( Vector2( 105 + STEPS, 49 ) )

func draw_nodes():
	for point in get_children():
		draw_circle( point.get_pos(), 7, Color( 1.0, 0.5, 0.5 ) )

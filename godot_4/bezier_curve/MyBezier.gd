extends Node2D
const POINT_PICK_DISTANCE = 10.0
var point_picked = false
var selected_point = null
@onready var point_A = $point_1
@onready var point_B = $point_2
@onready var point_C = $point_3
@onready var point_D = $point_4

func _process(delta):
	queue_redraw()

func _input(event):
	if event is InputEventMouseMotion:
		if point_picked:
			if selected_point != null:
				selected_point.set_position(event.position)
		else:
			selected_point = null
			for point in get_children():
				if event.position.distance_to(point.position) < POINT_PICK_DISTANCE:
					selected_point = point
	if event is InputEventMouseButton:
		if event.pressed:
			point_picked = true
			selected_point = null
			for point in get_children():
				if event.position.distance_to(point.position) < POINT_PICK_DISTANCE:
					selected_point = point
		else:
			point_picked = false
			selected_point = null

func get_bezier_linear(P_0:Vector2, P_1:Vector2, t:float) ->Vector2:
	return P_0 * (1-t) + P_1 * t 

func get_bezier( P_0:Vector2, P_1:Vector2, P_2:Vector2, P_3:Vector2, t:float) -> Vector2:
	var t_1 = 1.0 - t
	return pow(t_1,3)*P_0 + 3*t*pow(t_1,2)*P_1 + 3*pow(t,2)*t_1*P_2 + pow(t,3)*P_3

func get_bezier_brute_force(P_0:Vector2, P_1:Vector2, P_2:Vector2, P_3:Vector2, t:float) -> Vector2:
	var P_AB = get_bezier_linear(point_A.position, point_B.position, t)
	var P_BC = get_bezier_linear(point_B.position, point_C.position, t)
	var P_CD = get_bezier_linear(point_C.position, point_D.position, t)
	var P_ABBC = get_bezier_linear(P_AB, P_BC, t)
	var P_BCCD = get_bezier_linear(P_BC, P_CD, t)
	var P_t = get_bezier_linear(P_ABBC, P_BCCD, t)
	return P_t

func _draw():
	draw_line(point_A.position, point_B.position, Color(1,1,1,0.3), 1)
	draw_line(point_B.position, point_C.position, Color(1,1,1,0.3), 1)
	draw_line(point_C.position, point_D.position, Color(1,1,1,0.3), 1)
	var t = float(get_parent().offset) / get_parent().steps
	var P_AB = get_bezier_linear(point_A.position, point_B.position, t)
	var P_BC = get_bezier_linear(point_B.position, point_C.position, t)
	var P_CD = get_bezier_linear(point_C.position, point_D.position, t)
	draw_circle(P_AB, 3, Color.YELLOW)
	draw_circle(P_BC, 3, Color.YELLOW)
	draw_circle(P_CD, 3, Color.YELLOW)
	
	draw_line(P_AB, P_BC, Color(1,1,1,0.3), 1)
	draw_line(P_BC, P_CD, Color(1,1,1,0.3), 1)
	
	var P_ABBC = get_bezier_linear(P_AB, P_BC, t)
	var P_BCCD = get_bezier_linear(P_BC, P_CD, t)
	draw_circle(P_ABBC, 3, Color.GREEN)
	draw_circle(P_BCCD, 3, Color.GREEN)
	
	draw_line(P_ABBC, P_BCCD, Color(1,1,1,0.3), 1)
	
	var P_t = get_bezier_linear(P_ABBC, P_BCCD, t)
	draw_circle(P_t, 5, Color.WHITE)
	
	draw_handles()
	draw_bezier()

func draw_bezier():
	var t := 0.0
	for i in get_parent().steps :
		t = float(i) / get_parent().steps
		var from = get_bezier_brute_force(point_A.position, point_B.position, point_C.position, point_D.position, t)
		t = float(i+1) / get_parent().steps
		var to = get_bezier_brute_force(point_A.position, point_B.position, point_C.position, point_D.position, t)
		
		draw_line(from, to, Color.WHITE, 1, true)

func draw_handles():
	for point in get_children():
		draw_circle(point.position, 7, Color(1.0, 0.5, 0.5))
		
	if selected_point != null:  # draw selected point
		draw_circle(selected_point.position, 20, Color(1, 1, 1, 0.3))

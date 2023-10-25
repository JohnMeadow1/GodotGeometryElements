#@tool
extends Node2D

const POINT_PICK_DISTANCE = 10.0
var point_picked = false
var selected_point = null

@export var offset = 0 # (int, 0, 100)
@export var steps = 100 # (int, 0, 100)


func _process(_delta):
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


func _draw():
	draw_points()
	draw_bezier()

	if selected_point != null:  # draw selected point
		draw_circle(selected_point.position, 20, Color(1, 1, 1, 0.3))


func get_bezier_1(l_offset, A, B): # equivalent to linear interpolation (see docs: lerp)
	var t = float(l_offset) / steps
	return (1 - t) * A + t * B


func get_bezier_2(l_offset, A, B, C): # quadratic
	var t = float(l_offset) / steps
	var t_1 = 1 - t
	return pow(t_1, 2) * A + 2 * t * t_1 * B + pow(t, 2) * C


func get_bezier_3(l_offset, A, cA, B, cB): # cubic
	var t = float(l_offset) / steps
	var t_1 = 1 - t
	return pow(t_1, 3) * A + 3 * t * pow(t_1, 2) * cA + 3 * pow(t, 2) * t_1 * cB + pow(t, 3) * B


func draw_bezier():
	if get_child_count() == 2:
		var A  = get_child(0).position
		var B  = get_child(1).position

		draw_line(A, B, Color(1, 1, 0), 1)
		draw_circle(get_bezier_1(offset, A, B), 5, Color(0, 1, 0 ))

	elif get_child_count() == 3:
		var A = get_child(0).position
		var B = get_child(1).position # control point
		var C = get_child(2).position

		var points = []
		var point = Vector2()
		for step in steps + 1:
			point = get_bezier_2(step, A, B, C)
			points.push_back(point)

		for p in steps:
			draw_line(points[p], points[p + 1], Color(1, 1, 0), 1)
		draw_circle(get_bezier_2(offset, A, B, C), 5, Color(0, 1, 0))

		# draw support lines and circles
		draw_line(A, B, Color(1, 1, 1, 0.5), 1)
		draw_line(B, C, Color(1, 1, 1, 0.5), 1)
		draw_line(get_bezier_1(offset, A, B), get_bezier_1(offset, B, C), Color(1, 1, 1, 0.5), 1)
		draw_circle(get_bezier_1(offset, A, B), 5, Color(0, 1, 0, 0.5))
		draw_circle(get_bezier_1(offset, B, C), 5, Color(0, 1, 0, 0.5))

	elif get_child_count() == 4:
		var A  = get_child(0).position
		var cA = get_child(1).position # control point
		var cB = get_child(2).position # control point
		var B  = get_child(3).position

		var points = []
		var point = Vector2()
		for step in steps + 1:
			point = get_bezier_3(step, A, cA, B, cB)
			points.push_back(point)

		for p in steps:
			draw_line(points[p], points[p + 1], Color(1, 1, 0), 1)

		draw_circle(get_bezier_3(offset, A, cA, B, cB), 5, Color(0,1,0))

		# draw control lines
		draw_line(A, cA, Color(1, 1, 1, 0.5), 1)
		draw_line(cB, B, Color(1, 1, 1, 0.5), 1)

		# draw support lines and circles
		draw_line(cA, cB, Color(1, 1, 1, 0.5), 1)

		var A_cA  = get_bezier_1(offset, A, cA)
		var cA_cB = get_bezier_1(offset, cA, cB)
		var cB_B  = get_bezier_1(offset, cB, B)
		var P_1 = get_bezier_1(offset, A_cA , cA_cB)
		var P_2 = get_bezier_1(offset, cA_cB, cB_B)

		draw_line(A_cA, cA_cB, Color(1, 1, 1, 0.3), 1)
		draw_line(cA_cB, cB_B, Color(1, 1, 1, 0.3), 1)
		draw_line(P_1, P_2, Color(1, 1, 1, 0.5), 1)
		draw_circle(A_cA, 3, Color(0, 1, 0, 0.5))
		draw_circle(cA_cB, 3, Color(0, 1, 0, 0.5))
		draw_circle(cB_B, 3, Color(0, 1, 0, 0.5))
		draw_circle(P_1, 3, Color(0, 1, 0, 0.5))
		draw_circle(P_2, 3, Color(0, 1, 0, 0.5))


func draw_points():
	for point in get_children():
		draw_circle(point.position, 7, Color(1.0, 0.5, 0.5))

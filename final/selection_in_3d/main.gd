tool
extends Node

var pressed = false
var selection_view_rect_start_point = Vector2(0, 0)
var selection_view_rect_end_point = Vector2(0, 0)

func _ready():
	for node in $Objects.get_children():
		node.translation = Vector3(rand_range(-3,3), rand_range(-3,3), rand_range(-3,3))

func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		handle_mouse_button_event(event)
	if event is InputEventMouseMotion:
		handle_mouse_motion_event(event)
		$Gui/SelectionRectangle.draw_selection(selection_view_rect_start_point,selection_view_rect_end_point)

func handle_mouse_button_event(event):
	if event.button_index == 1:
		if event.pressed:
			pressed = true
			selection_view_rect_start_point = event.position
		else:
			pressed = false
			selection_view_rect_end_point = event.position
			handle_selection()
			
func handle_mouse_motion_event(event):
	if pressed:
		selection_view_rect_end_point = event.position
	else:
		selection_view_rect_end_point = selection_view_rect_start_point
	
func handle_selection():
	if (selection_view_rect_end_point - selection_view_rect_start_point).length_squared() != 0:
		# calculate top_left and bottom_right selection points in view space
		var top_left_view_selection_point = Vector2(min(selection_view_rect_start_point.x, selection_view_rect_end_point.x), min(selection_view_rect_start_point.y, selection_view_rect_end_point.y))
		var bottom_right_view_selection_point = Vector2(max(selection_view_rect_start_point.x, selection_view_rect_end_point.x), max(selection_view_rect_start_point.y, selection_view_rect_end_point.y))

		# calculate top_left, bottom_right, bottom_left and top_right selection points in world space
		var top_left_world_selection_frustum_point = $Enviroment/Camera.project_position(top_left_view_selection_point)
		var bottom_right_world_selection_frustum_point = $Enviroment/Camera.project_position(bottom_right_view_selection_point)
		var bottom_left_world_selection_frustum_point = $Enviroment/Camera.project_position(Vector2(top_left_view_selection_point.x, bottom_right_view_selection_point.y))
		var top_right_world_selection_frustum_point = $Enviroment/Camera.project_position(Vector2(bottom_right_view_selection_point.x, top_left_view_selection_point.y))

		# calculate top_left and bottom_right frustum rays normals in world space
		var top_left_world_selection_frustum_normal = $Enviroment/Camera.project_ray_normal(top_left_view_selection_point)
		var bottom_right_world_selection_frustum_normal = $Enviroment/Camera.project_ray_normal(bottom_right_view_selection_point)

		# calculate another top_left and bottom_right selection points in world space (for calculating frustum planes)
		var top_left_world_selection_frustum_point_2 = top_left_world_selection_frustum_point + top_left_world_selection_frustum_normal;
		var bottom_right_world_selection_frustum_point_2 = bottom_right_world_selection_frustum_point + bottom_right_world_selection_frustum_normal;

		# calculate selection frustum planes in world space
		var selection_frustum_left_plane = get_plane(top_left_world_selection_frustum_point, bottom_left_world_selection_frustum_point, top_left_world_selection_frustum_point_2)
		var selection_frustum_top_plane = get_plane(top_left_world_selection_frustum_point, top_left_world_selection_frustum_point_2, top_right_world_selection_frustum_point)
		var selection_frusutm_right_plane = get_plane(bottom_right_world_selection_frustum_point, top_right_world_selection_frustum_point, bottom_right_world_selection_frustum_point_2)
		var selection_frustum_bottom_plane = get_plane(bottom_right_world_selection_frustum_point, bottom_right_world_selection_frustum_point_2, bottom_left_world_selection_frustum_point)

		for node in $Objects.get_children():
			# test if node origin is iniside selection frustum
			if(get_signed_distance_from_plane(node.translation, selection_frustum_left_plane) > 0 && 
			get_signed_distance_from_plane(node.translation, selection_frustum_top_plane) > 0 && 
			get_signed_distance_from_plane(node.translation, selection_frusutm_right_plane) > 0 && 
			get_signed_distance_from_plane(node.translation, selection_frustum_bottom_plane) > 0):
				node.material_override.set("albedo_color", Color( 0, 1, 0 ) )
			else:
				node.material_override.set("albedo_color", Color( 1, 0, 0 ) )
	else:
		for node in $Objects.get_children():
			node.material_override.set("albedo_color", Color( 1, 0, 0 ) )

func get_plane( P1, P2, P3):
	var p1_to_p2 = P2 - P1
	var p1_to_p3 = P3 - P1
	var normal = p1_to_p2.cross(p1_to_p3)
	normal = normal.normalized();
	var a = -normal.dot(P1)
	return Plane(normal, a)

func get_signed_distance_from_plane( point, plane ):
	return plane.normal.dot(point) + plane.d;

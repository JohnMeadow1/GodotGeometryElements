extends "res://scripts/common_functions.gd"

const SELECTION_RANGE = 20
var pressed           = false
var pressed_ctrl      = false
var selection         = null
enum VECTOR_SELECTION_POINT {
	VECTOR_START,
	VECTOR_LINE,
	VECTOR_END
}

var vector_selection_point

var selected_point    = false

var selected_vector   = null

var vector_object     = preload("res://scenes/vector.tscn")

var color_array       = [Color(.39,.68,.21),Color(1,1,.32),Color(.98,.6,.07),Color(1,.15,.07),Color(.51,0,.65),Color(.07,.27,.98)]
var color_iterator    = 0

func _ready():
	$vector_addition.vector1 = $world/vector_1
	$vector_addition.vector2 = $world/vector_2
	
	$dot_product.vector1 = $world/vector_1
	$dot_product.vector2 = $world/vector_2
	
	$projection.vector1  = $world/vector_1
	$projection.vector2  = $world/vector_2

func _physics_process(delta):
	queue_redraw()

func _input(event):
	""" Mouse vector picking """
	if event is InputEventKey and event.keycode == KEY_CTRL :
		if event.pressed:
			pressed_ctrl = true
		else:
			pressed_ctrl = false

	if event is InputEventMouseMotion:
		handle_mouse_motion_event(event)

	if event is InputEventMouseButton:
		handle_mouse_button_event(event)

func handle_mouse_motion_event(event):
	if pressed:
		if selection != null:
			if vector_selection_point == VECTOR_SELECTION_POINT.VECTOR_START:
				selection.set_position(Vector2(round( float(get_global_mouse_position().x ) / 10 ) * 10,round( float(get_global_mouse_position().y ) / 10 ) * 10))
			else: 
				selection.set_vector(Vector2(round( float(get_global_mouse_position().x ) / 10 ),round( float(get_global_mouse_position().y ) / 10 ))-selection.position/10)
			update_GUI_vector_selection(selected_vector)
	else:
		selection = null
		for node in $world.get_children():
			if get_global_mouse_position().distance_to(node.position) < SELECTION_RANGE:
				selection    = node
				vector_selection_point = VECTOR_SELECTION_POINT.VECTOR_START
			elif node.is_vector:
				if get_global_mouse_position().distance_to(node.position + node.get_actual_vector()) < SELECTION_RANGE:
					selection    = node
					vector_selection_point = VECTOR_SELECTION_POINT.VECTOR_END
				else:
					if point_at_distance_from_vector(node.position, node.get_actual_vector(), get_global_mouse_position(), SELECTION_RANGE):
						selection = node
						vector_selection_point = VECTOR_SELECTION_POINT.VECTOR_LINE

func handle_mouse_button_event(event):
	if event.pressed:
		pressed   = true
		selection = null
		for node in $world.get_children():
			if get_global_mouse_position().distance_to(node.position) < SELECTION_RANGE:
				selected_vector = node
				selection       = node
				check_control_click(node)
				if event.doubleclick:
					check_vector_doubleclick(node)
			elif node.is_vector && get_global_mouse_position().distance_to(node.position + node.get_actual_vector()) < SELECTION_RANGE:
				selected_vector = node
				selection       = node
				check_control_click(node)
	else:
		pressed   = false
		selection = null

func check_vector_doubleclick(node):
	if node.is_vector:
		for point in $world.get_children():
			if !point.is_vector:
				point.move_by_vector(node.get_actual_vector())
				
func check_control_click(node):
	if pressed_ctrl && !node.is_vector:
		if selected_point:
			if selected_point != node:
				spawn_vector(selected_point.position, node.position)
				selected_point = null
		else:
			selected_point = node
	elif pressed_ctrl && node.is_vector:
		select_vector( node )
		
func select_vector( value ):
	$vector_addition.swap_vectors( value )
	$dot_product.swap_vectors( value )
	$projection.swap_vectors( value )

func spawn_vector(origin, target):
	var new_vector = vector_object.instantiate()
	new_vector.position = origin
	$world.add_child(new_vector)
	new_vector.set_vector( (target - origin)/10 )
	new_vector.update_vector_color(color_array[color_iterator])
	color_iterator += 1
	color_iterator %= color_array.size()

func update_GUI_vector_selection(node):
	if node.is_vector:
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/magnitude_box/magnitude.value = node.magnitude
		
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/direction_box/x.value = node.direction.x
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/direction_box/y.value = node.direction.y
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/vector/x.value        = node.get_vector().x
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/vector/y.value        = node.get_vector().y

func draw_grid( grid_size, color ):
	""" draw grid """
	var viewport_range = Vector2(get_viewport().size.x/2, get_viewport().size.y/2)
	
	for x in range( round( viewport_range.x / grid_size )  ):
		draw_line( Vector2(  (x+1) * grid_size, - viewport_range.y ), Vector2(  (x+1) * grid_size , viewport_range.y ), color, 1 )
		draw_line( Vector2( -(x+1) * grid_size, - viewport_range.y ), Vector2( -(x+1) * grid_size , viewport_range.y ), color, 1 )
		
	for x in range( round( viewport_range.y / grid_size )  ):
		draw_line( Vector2( - viewport_range.x,  (x+1) * grid_size ), Vector2( viewport_range.x,  (x+1) * grid_size ), color, 1 )
		draw_line( Vector2( - viewport_range.x, -(x+1) * grid_size ), Vector2( viewport_range.x, -(x+1) * grid_size ), color, 1 )
		
func draw_axis( color ):
	draw_line( Vector2( -get_viewport().size.x*0.5, 0 ), Vector2(  get_viewport().size.x*0.5, 0 ), color, 1 )
	draw_line( Vector2( 0, -get_viewport().size.y*0.5 ), Vector2(  0, get_viewport().size.y*0.5 ), color, 1 )
	
func _draw():
	if selection != null:  # draw selected node
		selection.timer = 1
		if vector_selection_point == VECTOR_SELECTION_POINT.VECTOR_START:
			draw_circle( selection.position, SELECTION_RANGE, Color( 1, 1, 1, 0.3 ) )
		elif vector_selection_point == VECTOR_SELECTION_POINT.VECTOR_END: 
			draw_circle( selection.position + selection.get_actual_vector(), SELECTION_RANGE, Color( 1, 1, 1, 0.3 ) )
	draw_grid( 20,  Color( 1, 1, 1, 0.1 ) )
	draw_grid( 100, Color( 1, 1, 1, 0.2 ) )
	draw_axis( Color( 1, 1, 1, 0.5 ) )
	
func _on_magnitude_value_changed(value):
	if !selected_vector == null:
		selected_vector.set_magnitude(value)
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/vector/x.value = selected_vector.get_vector().x
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/vector/y.value = selected_vector.get_vector().y
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/direction_box/x.value = selected_vector.get_vector().normalized().x
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/direction_box/y.value = selected_vector.get_vector().normalized().y

func _on_y_value_changed(value):
	if !selected_vector == null:
		selected_vector.set_vector( Vector2( selected_vector.get_vector().x, value ) )
#		update_GUI_vector_selection(selected_vector)
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/magnitude_box/magnitude.value = selected_vector.get_vector().length()
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/direction_box/x.value = selected_vector.get_vector().normalized().x
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/direction_box/y.value = selected_vector.get_vector().normalized().y

func _on_x_value_changed(value):
	if !selected_vector == null:
		selected_vector.set_vector( Vector2( value, selected_vector.get_vector().y ) )
#		update_GUI_vector_selection(selected_vector)
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/magnitude_box/magnitude.value = selected_vector.get_vector().length()
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/direction_box/x.value = selected_vector.get_vector().normalized().x
		$GUI_layer/Margin/HBox/VBox/HBox/VBox/direction_box/y.value = selected_vector.get_vector().normalized().y

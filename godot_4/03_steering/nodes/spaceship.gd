extends Node2D

const ACCELERATION := 50.0
const ANGULAR_ACCELERATION := 0.5
var speed := 0.0
var velocity := Vector2()
var angular_velocity := 0.0
var thrust := 0.0
var angular_thrust := 0.0

var orientation := 0.0
var heading := Vector2(1,0)
var vector_to_mouse :Vector2
var fov_radius := 100
var fov_angle := deg_to_rad(90)
var in_field_of_view := false
@onready var sprite_2d = $Sprite2D as Sprite2D

var is_mouse_control := false

func _process(delta):
	process_input()
	$Label.text = str(orientation)
	
	if is_mouse_control:
		vector_to_mouse = get_global_mouse_position() - position
		var dot = heading.dot(vector_to_mouse.normalized())
		var cross = heading.cross(vector_to_mouse.normalized())
		var angle_to_mouse = atan2(cross, dot) * 10.0
		orientation += angle_to_mouse * delta
	else:
		angular_velocity += angular_thrust * delta
		orientation += angular_velocity
		angular_velocity *= 0.9
		
	heading = Vector2(cos(orientation), sin(orientation))
	
	velocity += heading * thrust * delta
	velocity *= 0.95
	position += velocity
	sprite_2d.rotation = orientation
	queue_redraw()

func process_input():
	thrust = 0
	angular_thrust = 0
	if Input.is_action_pressed("RIGHT"):
		angular_thrust = ANGULAR_ACCELERATION
	if Input.is_action_pressed("LEFT"):
		angular_thrust = -ANGULAR_ACCELERATION
	if Input.is_action_pressed("UP"):
		thrust = ACCELERATION
	if Input.is_action_pressed("DOWN"):
		thrust = -ACCELERATION

func _draw():
	draw_vector(Vector2(0,0), velocity*20, Color.WHITE, 2) 
	draw_vector(Vector2(0,0), heading*60, Color.GREEN, 2) 
	if in_field_of_view:
		draw_vector(Vector2(0,0), vector_to_mouse, Color.BLUE, 2)
	else:
		draw_vector(Vector2(0,0), vector_to_mouse, Color.RED, 2) 
	draw_fov_arc( fov_radius, fov_angle)
	
func draw_vector( origin, vector, color, arrow_size ):
	if vector.length_squared() > 1:
		var points    = []
		var direction = vector.normalized()
		vector += origin
		vector -= direction * arrow_size*2
		points.push_back( vector + direction * arrow_size*2  )
		points.push_back( vector + direction.rotated(  PI / 1.5 ) * arrow_size * 2 )
		points.push_back( vector + direction.rotated( -PI / 1.5 ) * arrow_size * 2 )
		draw_polygon( PackedVector2Array( points ), PackedColorArray( [color] ) )
		vector -= direction * arrow_size*1
		draw_line( origin, vector, color, arrow_size )
		
func draw_fov_arc(radius, angle):
	var angle_from = orientation + angle / 2.0 
	var angle_to   = orientation - angle / 2.0
	draw_circle_arc(radius, angle_from, angle_to)
		
func draw_circle_arc(radius, angle_from, angle_to):
	var nb_points = 16
	var points_arc = PackedVector2Array()

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to-angle_from) / nb_points
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], Color.WHEAT)
	draw_line( Vector2.ZERO, Vector2( cos( angle_from ), sin( angle_from )) * radius, Color.WHEAT)
	draw_line( Vector2.ZERO, Vector2( cos( angle_to )  , sin( angle_to ))   * radius, Color.WHEAT)

#	orientation = lerp(orientation, atan2(vector_to_mouse.y, vector_to_mouse.x), 0.01)
#	orientation += atan2(heading.cross(vector_to_mouse), heading.dot(vector_to_mouse) ) * delta 
#	orientation += heading.angle_to(vector_to_mouse) * delta * 5



#	vector_to_mouse = get_global_mouse_position() - position
#	heading = Vector2( cos(orientation), sin(orientation) )
##	$Label.text = str(heading.dot(vector_to_mouse.normalized())," ",fov_angle)
#	var angle_to_mouse =  acos(heading.dot(vector_to_mouse.normalized())) 
#	if angle_to_mouse < fov_angle/2.0:
#		in_field_of_view = true
#	else:
#		in_field_of_view = false
#
#
#	velocity += heading * speed * delta
#	velocity *= 0.99
#	position += velocity * delta


#	heading = Vector2(cos(angle), sin(angle))
#	vector_to_mouse = get_global_mouse_position() - position
#	position += velocity * delta
##	sprite_2d.rotation = atan2(velocity.y, velocity.x)
##	sprite_2d.rotation = vector_to_mouse.angle()
##	angle = lerp(angle,  vector_to_mouse.angle(), 0.05)
#	var p_dot = heading.normalized().dot(vector_to_mouse)
#	var p_cross = heading.normalized().cross(vector_to_mouse)
#
#	angle += atan2(p_cross,p_dot) * delta
#	angle += heading.angle_to(vector_to_mouse) * delta
#
#	sprite_2d.rotation = angle

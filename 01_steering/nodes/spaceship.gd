extends Node2D

const ACCELERATION := 400.0
const ANGULAR_ACCELERATION := 12.0
var speed := 0.0
var velocity := Vector2()
var angular_velocity := 0.0

var orientation := 0.0
var heading := Vector2.RIGHT
var vector_to_mouse :Vector2
var fov_radius := 300
var fov_angle := deg_to_rad(70)
var in_field_of_view := false

var thrust :float = 0.0
var thrust_angular :float = 0.0
var LMB :bool = false

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var asteroid: AnimatedSprite2D = $"../Asteroid"
var vector_to_asteroid := Vector2.ZERO
var projection_on_heading := Vector2.ZERO
var perpendicular_on_heading := Vector2.ZERO

var projection_length := 0.0
var perpendicular_length := 0.0

func process_asteroid(delta:float):
	vector_to_asteroid
	projection_on_heading
	perpendicular_on_heading 
	perpendicular_length 

func _process(delta):
	process_input()

	sprite_2d.rotation = orientation
	queue_redraw()
	
func process_input():
	thrust_angular = 0.0


func _draw():
	draw_vector(Vector2.ZERO, velocity, Color(1,1,1), 2) 
	draw_vector(Vector2.ZERO, heading*60, Color.GREEN, 2) 
	
	draw_vector(Vector2.ZERO, vector_to_asteroid, Color.AQUAMARINE, 5)
	if projection_length > 0.0:
		draw_vector(Vector2.ZERO, projection_on_heading, Color(0,1,0,0.3), 5)
	else:
		draw_vector(Vector2.ZERO, projection_on_heading, Color(1,0,0,0.3), 5)
	
	if abs(perpendicular_length) > 60:
		draw_vector(projection_on_heading, perpendicular_on_heading, Color(0,1,0,0.3), 5)
	else:
		draw_vector(projection_on_heading, perpendicular_on_heading,  Color(1,0,0,0.3), 5)
	
	$Label.text = str("(",round(projection_length), "),  (", round(perpendicular_length), ")")
	
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

#func process_asteroid(delta:float):
#	vector_to_asteroid = asteroid.position - position
#	projection_on_heading = vector_to_asteroid.project(heading)
#	perpendicular_on_heading = vector_to_asteroid - projection_on_heading
#	perpendicular_length = perpendicular_on_heading.length()
#	
#	var repulsion_distance := 300.0
#	if heading.dot(vector_to_asteroid) >= 0.0:
#		if vector_to_asteroid.length() < repulsion_distance:
#			if perpendicular_length < 60:
#				var repulsion_force = 1.0 - (projection_length / repulsion_distance)
#				velocity -= perpendicular_on_heading.normalized() * 100 * repulsion_force * delta
#		

#func _process(delta):
#	process_input()
#	
#	vector_to_mouse = get_global_mouse_position() - position
#	#var angle_to_mouse = atan2(heading.cross(vector_to_mouse), heading.dot(vector_to_mouse))
#	var angle_to_mouse = heading.angle_to(vector_to_mouse)
#	
#	if LMB:
#		orientation += angle_to_mouse * delta
#	else:
#		angular_velocity += thrust_angular * ANGULAR_ACCELERATION * delta
#		orientation += angular_velocity * delta
#		angular_velocity -= angular_velocity * 4.0 * delta
#	
#	in_field_of_view = false
#	if vector_to_mouse.length() <= fov_radius:
#		if abs(angle_to_mouse) <= fov_angle / 2.0:
#			in_field_of_view = true
#			
#	#heading = Vector2(cos(orientation), sin(orientation))
#	heading = Vector2.from_angle(orientation)
#	
#	process_asteroid(delta)
#	
#	velocity += heading * thrust * ACCELERATION * delta
#	velocity -= velocity * 1.0 * delta
#	position += velocity * delta
#	
#	sprite_2d.rotation = orientation
#	queue_redraw()
#	
#func process_input():
#	thrust_angular = 0.0
#	if Input.is_action_pressed("RIGHT"):
#		thrust_angular = 1
#	if Input.is_action_pressed("LEFT"):
#		thrust_angular = -1
#		
#	thrust = 0.0
#	if Input.is_action_pressed("UP"):
#		thrust = 1
#	if Input.is_action_pressed("DOWN"):
#		thrust = -1
#		
#	if Input.is_action_pressed("BOOST"):
#		thrust *= 4.0
#		
#	LMB = false
#	if Input.is_action_pressed("LMB"):
#		LMB = true

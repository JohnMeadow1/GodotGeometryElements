extends Node2D

const ACCELERATION = 0.3
const ANGULAR_ACC  = 0.01

var angular_velocity = 0 

var velocity = Vector2( 1.0, 0.0 )
var heading  = Vector2( 0.0, 0.0 )
var orientation = 0

var speed    = 0
var thrust   = 0 

var use_mouse_stering = false
var vector_mouse = Vector2( 0.0, 0.0 )

func _process( delta ):
	process_input( delta )
	vector_mouse = get_global_mouse_position() - position
	if use_mouse_stering:
		# using godot
		var angle_to_target = heading.angle_to(vector_mouse)
		# using math by hand
#		var angle_to_target = atan2(heading.x*vector_mouse.y - heading.y*vector_mouse.x,
#									heading.x*vector_mouse.x + heading.y*vector_mouse.y )
		angular_velocity += angle_to_target * 0.005
		
	angular_velocity *= 0.95 # fake angular friction
	orientation += angular_velocity
	heading   = Vector2( cos(orientation), sin(orientation))
	velocity += heading * thrust
	velocity *= 0.97 # fake friction
	
	position += velocity
	$body.rotation = orientation
	
	update()

func process_input( delta ):
	thrust = 0
	if Input.is_action_pressed("ui_up"):
		$body/AnimationPlayer.play("thrust")
		thrust = ACCELERATION
	if Input.is_action_pressed("ui_down"):
		$body/AnimationPlayer.play("thrust")
		thrust = -ACCELERATION

	if Input.is_action_pressed("ui_left"):
		angular_velocity -= ANGULAR_ACC
	if Input.is_action_pressed("ui_right"):
		angular_velocity += ANGULAR_ACC

func _draw():
	draw_vector(Vector2(0,0), heading * 70, Color(1,1,1), 2) 
	draw_vector(Vector2(0,0), velocity * 50, Color(1,0,0), 2) 
	draw_vector(Vector2(0,0), vector_mouse, Color(0,1,0), 2) 

func draw_vector( origin, vector, color, arrow_size ):
	if vector.length_squared() > 1:
		var points    = []
		var direction = vector.normalized()
		vector += origin
		vector -= direction * arrow_size*2
		points.push_back( vector + direction * arrow_size*2  )
		points.push_back( vector + direction.rotated(  PI / 1.5 ) * arrow_size * 2 )
		points.push_back( vector + direction.rotated( -PI / 1.5 ) * arrow_size * 2 )
		draw_polygon( PoolVector2Array( points ), PoolColorArray( [color] ) )
		vector -= direction * arrow_size*1
		draw_line( origin, vector, color, arrow_size )
extends Node2D

var input_states = preload("input_states.gd")

var state_up    = input_states.new("up")
var state_down  = input_states.new("down")
var state_left  = input_states.new("left")
var state_right = input_states.new("right")

var btn_up      = null
var btn_down    = null
var btn_left    = null
var btn_right   = null

var position             = get_pos()
var velocity             = Vector2( 3.0, 0.0 )
var thrust               = 0

var angular_velocity     = 0
var angular_acceleration = 0.005

var orientation          = 0
var facing               = Vector2( 0.0, 0.0 )

var gravity_enabled      = true
var gravity              = 0
var gravity_vector       = Vector2( 0.0, 0.0 )
var mass                 = 1000

var vector_to_asteroid   = Vector2( 0.0, 0.0 )
onready var asteroid     = get_node("../Asteroid")

func _ready():
	set_fixed_process( true )
	pass
func _fixed_process(delta):
	process_input()
	vector_to_asteroid = asteroid.get_pos() - position
	
	angular_velocity = angular_velocity * 0.92
	orientation      = orientation + angular_velocity
	facing           = Vector2( cos( orientation ), - sin( orientation ) )

	# enable friction and dissable gravity for normal steering
#	velocity         = velocity * 0.98
	gravity          = mass / ( max( vector_to_asteroid.length_squared(), 5000 ) )
	
	gravity_vector   = vector_to_asteroid.normalized() * gravity
	velocity        += facing * thrust + gravity_vector
	position         = position + velocity

	get_node("Sprite").set_rot( orientation )
	set_pos( position )
	update()

func process_input():
	btn_up    = state_up.check()
	btn_down  = state_down.check()
	btn_left  = state_left.check()
	btn_right = state_right.check()

	thrust = 0
	if( btn_up   > 1 ):
		thrust = 0.15
	if( btn_down > 1 ):
		thrust = -0.15

	if( btn_left  > 1 ):
		angular_velocity += angular_acceleration
	if( btn_right > 1 ):
		angular_velocity -= angular_acceleration

func _draw():
	# actual vectors length is usually to short in order to draw them properly 
	draw_vector_from_spaceship( velocity * 20        , Color( 1.0 ,1.0 ,0.0, 0.5 ), 5 )
	draw_vector_from_spaceship( gravity_vector * 300 , Color( 0.0, 1.0, 0.0, 0.5 ), 5 )
	draw_vector_from_spaceship( facing * 50          , Color( 1.0 ,1.0 ,1.0, 0.5 ), 3 )
	draw_vector_from_spaceship( facing * thrust * 500, Color( 0.0, 1.0, 0.0, 0.5 ), 5 )

func draw_vector_from_spaceship( vector, color, arrow_size ):
	if vector.length_squared() > 1:
		var points    = []
		var direction = vector.normalized()
		points.push_back( vector + direction * arrow_size * 2 )
		points.push_back( vector + direction.rotated(  PI / 2 ) * arrow_size )
		points.push_back( vector + direction.rotated( -PI / 2 ) * arrow_size )
		draw_polygon( Vector2Array( points ), ColorArray( [color] ) )
		draw_line( Vector2( 0.0, 0.0 ), vector, color, arrow_size )
extends Node2D

var input_states = preload("input_states.gd")

var state_up    = input_states.new("up")
var state_down  = input_states.new("down")
var state_left  = input_states.new("left")
var state_right = input_states.new("right")
var state_fire  = input_states.new("fire")

var btn_up      = null
var btn_down    = null
var btn_left    = null
var btn_right   = null
var btn_fire    = null

var position             = get_pos()
var velocity             = Vector2( 4.0, 0.0 )
var thrust               = 0

var angular_velocity     = 0
var angular_acceleration = 0.005

var orientation          = 0
var facing               = Vector2 ( 0.0, 0.0 )

var use_gravity          = false
var gravity_force        = 0
var gravity_vector       = Vector2 ( 0.0, 0.0 )
var mass                 = 1000

var vector_to_asteroid   = Vector2 ( 0.0, 0.0 )
var distance_to_asteroid = 0
onready var asteroid     = get_parent().get_node("Asteroid")

var projection           = Vector2 ( 0.0, 0.0 )

var collision_distance   = 0
var collision_vector     = Vector2 ( 0.0, 0.0 )

var dot                  = 0
var cross                = 0

var bullet               = preload("res://scenes/bullet.tscn")

func _ready():
	set_fixed_process( true )

func _fixed_process( delta ):
	process_input()

	vector_to_asteroid   = asteroid.get_pos() - position
	distance_to_asteroid = min( vector_to_asteroid.length(), 500 )

	projection = get_projection(    facing, vector_to_asteroid )
	dot        = get_dot_product(   facing, vector_to_asteroid )
	cross      = get_cross_product( facing, vector_to_asteroid )

	collision_vector   = projection - vector_to_asteroid
	collision_distance = collision_vector.length()

	# avoid asteroid collision
	if dot > 0 && collision_distance < 60 && distance_to_asteroid < 400:
		# simple solution
#		angular_velocity += cross * 0.00003
		# not so simple solution
		angular_velocity += sign( cross ) * ( 60 - abs( cross ) ) * 0.0001 * ( 400 - distance_to_asteroid ) / 400

	angular_velocity = angular_velocity * 0.91
	orientation      = orientation + angular_velocity
	facing           = Vector2 ( cos( orientation ), -sin( orientation ) )

	if use_gravity:
		gravity_force  = mass / ( max( vector_to_asteroid.length_squared(), 5000 ) )
		gravity_vector = vector_to_asteroid.normalized() * gravity_force
	else:
		velocity       = velocity * 0.97

	velocity = velocity + (facing * thrust) + gravity_vector
	position = position + velocity

	print_location()
	get_node("Sprite").set_rot( orientation )
	set_pos( position )
	update()

func print_location():
	var string = "Asteroid:\ndistance: " + str( int( distance_to_asteroid ) ) + "px\nlocation: "

	if dot > 0:
		string += "front"
	else:
		string += "back"

	if cross > 0:
		string += " right"
	else:
		string += " left"

	if btn_fire: 
		string += "\nFiring"
	get_node("../Label").set_text( string )



func process_input():
	btn_up    = state_up.check()
	btn_down  = state_down.check()
	btn_left  = state_left.check()
	btn_right = state_right.check()
	btn_fire  = state_fire.check()

	thrust = 0
	if btn_up   > 1:
		thrust = 0.15
	if btn_down > 1:
		thrust = -0.15

	if btn_left  > 1:
		angular_velocity += angular_acceleration
	if btn_right > 1:
		angular_velocity -= angular_acceleration

	if btn_fire  > 1:
		create_bullet()

func _draw():
	draw_vector( Vector2( 0, 0 ), velocity * 10     , Color( 1.0, 1.0, 0.0, 0.5 ), 5 )
	draw_vector( Vector2( 0, 0 ), facing * 60       , Color( 1.0, 1.0, 1.0, 0.5 ), 5 )
	draw_vector( Vector2( 0, 0 ), projection        , Color( 0.0, 1.0, 0.0, 0.5 ), 3 )
	draw_vector( Vector2( 0, 0 ), vector_to_asteroid, Color( 1.0, 1.0, 1.0, 0.5 ), 3 )

	if collision_distance < 60:
		draw_vector( vector_to_asteroid, projection, Color( 1.0, 0.0, 0.0, 0.5 ), 3)
	else:
		draw_vector( vector_to_asteroid, projection, Color( 0.0, 0.0, 1.0, 0.5 ), 3)

func draw_vector( origin, vector, color, arrow_size ):
	if vector.length_squared() > 1:
		var points    = []
		var direction = vector.normalized()
		points.push_back( vector + direction * arrow_size * 2 )
		points.push_back( vector + direction.rotated(  PI / 2 ) * arrow_size )
		points.push_back( vector + direction.rotated( -PI / 2 ) * arrow_size )
		draw_polygon( Vector2Array( points ), ColorArray( [color] ) )
		draw_line( origin, vector, color, arrow_size )

func create_bullet():
	var new_bullet = bullet.instance()
	new_bullet.set_pos( position )
	new_bullet.velocity = facing * rand_range( 2, 8 )
	get_node("../bullets").add_child( new_bullet )

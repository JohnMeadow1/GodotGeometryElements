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
var velocity             = Vector2( 0.0, 0.0 )
var thrust               = 0

var angular_velocity     = 0
var angular_acceleration = 0.005

var orientation          = 0
var facing               = Vector2( 0.0, 0.0 )

func _ready():
	set_fixed_process( true )

func _fixed_process(delta):
	process_input()

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
		pass
	if( btn_down > 1 ):
		pass

	if( btn_left  > 1 ):
		pass
	if( btn_right > 1 ):
		pass

func _draw():
	pass

func draw_vector_from_spaceship( vector, color, arrow_size ):
	if vector.length_squared() > 1:
		var points    = []
		var direction = vector.normalized()
		points.push_back( vector + direction * arrow_size * 2 )
		points.push_back( vector + direction.rotated(  PI / 2 ) * arrow_size )
		points.push_back( vector + direction.rotated( -PI / 2 ) * arrow_size )
		draw_polygon( Vector2Array( points ), ColorArray( [color] ) )
		draw_line( Vector2( 0.0, 0.0 ), vector, color, arrow_size )
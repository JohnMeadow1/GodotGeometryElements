extends Node2D

onready var player = get_node( "../Spaceship" )
var bullet = preload("res://scenes/bullet.tscn")
var rocket = preload( "res://scenes/rocket.tscn" )

var vector_to_player = Vector2()
var orientation      = 90
var facing           = Vector2()
var velocity         = Vector2()

var laser_timer      = 0
var laser_delay      = 2.5
var rocket_timer     = 2
var rocket_delay     = 3

var target_heading   = 0
var target_solution  = false
var predictive_aim   = Vector2()

func _ready():
	set_fixed_process( true )

func _fixed_process( delta ):
	vector_to_player = player.get_pos() - get_pos()

	follow_player()
	calculate_targeting_solution( self, player, 10 )
	display_aiming()
	use_weapons(delta)

func follow_player():
	velocity *= 0.96
	if vector_to_player.length() > 400:
		velocity += vector_to_player.normalized() * ( vector_to_player.length() - 400 ) / 30
	set_pos( get_pos() + velocity )

	orientation = atan2( -vector_to_player.y, vector_to_player.x)
	facing      = Vector2 ( cos( orientation ), -sin( orientation ) )
	get_node("Sprite").set_rot( orientation )

func calculate_targeting_solution( origin, target, projectileVelocity ):
	target_solution  = false

func display_aiming():
	if target_solution:
		get_node("aim").set_pos( predictive_aim )
		get_node("aim").set_hidden( false )
		update()
	else:
		get_node("aim").set_hidden( true )

func use_weapons( delta ):
	laser_timer  += delta
	if laser_timer >= laser_delay:
		if laser_timer >= 3:
			laser_delay = rand_range( 1.8, 2.5 )
			laser_timer = 0
		laser_delay += ( rand_range( 0.05, 0.07 ) + rand_range( 0.05, 0.07 ) )
		if target_solution :
			create_bullet( target_heading )

	rocket_timer += delta
	if rocket_timer > rocket_delay:
		create_rocket()

func create_bullet( angle ):
	var new_bullet      = bullet.instance()
	new_bullet.id       = 1
	new_bullet.velocity = velocity + Vector2 ( cos( angle ), -sin( angle ) ) * 10
	new_bullet.set_pos( get_pos() )
	new_bullet.set_rot( angle )
	get_node("../bullets").add_child( new_bullet )

func create_rocket():
	rocket_timer           = 0
	var new_rocket         = rocket.instance()
	new_rocket.velocity    = vector_to_player.normalized()
	new_rocket.orientation = orientation
	get_node("../rockets").add_child( new_rocket )
	new_rocket.set_pos( get_pos() )

func _draw():
	if target_solution:
		draw_line( Vector2(), predictive_aim, Color( 1.0, 1.0, 0.0, 0.2 ) )

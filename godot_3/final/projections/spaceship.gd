extends Node2D

const ACCELERATION = 0.3
const ANGULAR_ACC  = 0.01

var angular_velocity = 0 

var velocity = Vector2( 6.0, 0.0 )
var heading  = Vector2( 1.0, 0.0 )
var orientation = 0

var speed    = 0
var thrust   = 0 

var vector_mouse = Vector2( 0.0, 0.0 )

var use_gravity = false
var use_mouse   = false

## begin --------------------------------
var vector_to_stone = Vector2( 0.0, 0.0 )
onready var stone   = get_node("../stone")
var projection      = Vector2( 0.0, 0.0 )
var stone_to_projection = Vector2( 0.0, 0.0 )

var bullet_object = load("res://bullet.tscn")

## --------------------------------
func get_projection( V, W ):
#	var scalar = W.x * V.x + W.y * V.y
#	var scalar = W.dot(V)
#	var length_V = V.x * V.x + V.y * V.y
#	var length_V = V.length_squared()
#	projection = (scalar / length_V ) * V
	projection = ( W.dot(V) / V.length_squared() ) * V

func _process( delta ):
	process_input( delta )

	vector_to_stone = stone.position - self.position
	get_projection( heading, vector_to_stone )
	stone_to_projection = projection - vector_to_stone
	
	var gravity = 5000 / max(2500, vector_to_stone.length_squared())
	var gravity_vector = vector_to_stone.normalized() * gravity
	
	## avoid asteroid
	if heading.dot(vector_to_stone) > 0:
		if stone_to_projection.length() < 100:
			var f = heading.tangent().dot(vector_to_stone.normalized()) * 0.01
			angular_velocity += f
	
	if use_mouse:
		target_mouse()
	angular_velocity *= 0.95
	orientation += angular_velocity
	heading   = Vector2( cos(orientation), sin(orientation))
	velocity += heading * thrust
	if use_gravity:
		velocity += gravity_vector
	else:
		velocity *= 0.97
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
		
	if Input.is_action_pressed("ui_select"):
		for i in range(10):
			var new_bullet = bullet_object.instance()
			new_bullet.position = position + Vector2(rand_range(-1,1),rand_range(-1,1))
			new_bullet.velocity = velocity + heading * 5
			get_parent().add_child(new_bullet)

func _draw():
	draw_vector(Vector2(0,0), heading * 100, Color(1,1,1), 4)
	draw_vector(Vector2(0,0), velocity * 50, Color(1,0,0), 4) 
	if use_mouse:
		draw_vector(Vector2(0,0), vector_mouse, Color(0,1,0), 4) 
	draw_vector(Vector2(0,0), vector_to_stone, Color(0,1,1), 4) 
	draw_vector(Vector2(0,0), projection, Color(1,1,0), 4) 
	if stone_to_projection.length() < 100:
		draw_vector(vector_to_stone, stone_to_projection, Color(1,0,0), 4) 
	else:
		draw_vector(vector_to_stone, stone_to_projection, Color(0,1,0), 4) 

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

func target_mouse():
	vector_mouse = get_global_mouse_position() - position
	var angle_to_target = heading.angle_to(vector_mouse)
	angular_velocity += angle_to_target * 0.005
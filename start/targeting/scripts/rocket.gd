extends Node2D

var position            = Vector2( )
var velocity            = Vector2( )
var orientation         = 0
var angular_v           = 0
var thrust              = 0
var ACCELERATION        = 0.3

var facing              = Vector2( )

onready var player      = get_node("../../Spaceship")
var vector_to_target    = Vector2()
var angle_to_target     = 0
var active              = true
var timer               = 0

func _ready():
	set_fixed_process(true)
	get_node("Node2D").set_rot(orientation)
	
func _fixed_process(delta):
	if (active):
		facing           = Vector2( cos(orientation), -sin(orientation) )

		thrust = ACCELERATION * 1
		velocity   += facing * thrust
		velocity   *= 0.975

		# player hit check
		if ( player.get_pos() - get_pos() ).length() < 30:
			player.hp -= 10
			destroy()
	else:
		timer += delta
		if (timer >0.4):
			queue_free()

	set_pos( get_pos() + velocity )
	update()

func get_aim_approximation():
	return 0

func get_dot( V, W ):
	return V.x * W.x + V.y * W.y

func get_cross( V, W ):
	return V.x * W.y - V.y * W.x

func destroy():
	active = false
	get_node("Node2D/AnimationPlayer").play("boom")

func _draw():
	draw_circle(vector_to_target, 5, Color(1,0,0,0.5))
	draw_line(Vector2(), vector_to_target,      Color(1,0,0,0.5))
	draw_line(Vector2(), velocity*10, Color(0,1,0,0.5))

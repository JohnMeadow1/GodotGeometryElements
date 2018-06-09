extends Node2D

var velocity            = Vector2( )
var orientation         = 0
var angular_v           = 0
var thrust              = 0
var ACCELERATION        = 0.3

var facing              = Vector2( )

onready var player      = get_node("../../Spaceship")
var target              = Vector2()
var angle_to_target     = 0
var active              = true
var timer               = 0

func _ready():
	pass
	
func _physics_process(delta):
	if (active):
		facing          = Vector2( cos(orientation), sin(orientation) )
		target          = player.position - self.position

		angle_to_target = aim_approximation()
		angle_to_target = clamp( angle_to_target, -0.15, 0.15 )
		orientation    += angle_to_target / PI
		get_node("Node2D").rotation = orientation

		var dot   = get_dot( target.normalized(), facing )
		if dot >0.9:
			dot = 1
		if dot < 0.8:
			dot = 0.1
		thrust = ACCELERATION * dot

		velocity   += facing * thrust
		velocity   *= 0.975

		# player hit check
		if ( player.position - self.position ).length() < 30:
			player.hp -= 10
			destroy()
	else:
		timer += delta
		if timer > 0.4:
			queue_free()

	self.position += velocity
	update()

func aim_approximation():
	var time_to_target = target.length() / velocity.length()
	target             = target + player.velocity * min ( time_to_target, 10 )

	var dot   = get_dot(   target, facing )
	var cross = get_cross( target, facing )
	return atan2( -cross, dot )

func get_dot( V, W ):
	return V.x * W.x + V.y * W.y

func get_cross( V, W ):
	return V.x * W.y - V.y * W.x

func destroy():
	active = false
	get_node("Node2D/AnimationPlayer").play("boom")

func _draw():
	draw_circle( target, 5, Color(1,0,0,0.5) )
	draw_line( Vector2(), target,        Color(1,0,0,0.5) )
	draw_line( Vector2(), velocity * 10, Color(0,1,0,0.5) )

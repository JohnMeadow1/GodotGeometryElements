tool 
extends Node2D; "common_functions.gd"

var is_vector = false
var timer     = 1

@onready var target_positon = position


func _ready():
	pass

func _process(delta):
	if timer>0:
		timer -= delta
		$label.modulate = Color (1,1,1, clamp(timer, 0,1))
		position = position.lerp(target_positon,0.15)
		if timer <=0 :
			position = target_positon
	update_label()

func move_by_vector(value):
	timer = 1
	target_positon += value
	
func set_position(value):
	position       = value
	target_positon = value

func update_label():
	$label.text = str("%4.1f" % (position.x/10) + ", " + "%4.1f" % (position.y/10) )

func _draw():
	draw_circle( Vector2(), 5, Color(1,1,1,0.4) )
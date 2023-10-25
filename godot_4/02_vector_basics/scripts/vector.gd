@tool
extends "res://scripts/common_functions.gd"

var        direction      = Vector2( 0.0, 1.0 ) 
var        magnitude      = 100.0

@export var initial_vector = Vector2( 50, 50 ): set = update_initial_vector
@export var vector_color   = Color( 1, 1, 1, 1 ): set = update_vector_color
@export var vector_width   = 3: set = update_vector_width

var is_ready  = false
var is_vector = true

var timer    = 1

func _ready():
	set_vector( initial_vector )
	$value.visible     = true
	$magnitude.visible = true
	is_ready           = true
	
func _process(delta):
	if timer >0:
		timer -= delta
		$value.modulate     = Color(1,1,1,max(timer,0))
		$magnitude.modulate = Color(1,1,1,max(timer,0))
	
	
func update_initial_vector(value):
	initial_vector = value
	direction      = value.normalized()
	magnitude      = value.length()
	if is_ready || Engine.is_editor_hint():
		set_vector( initial_vector )
	else:
		queue_redraw()
	
func get_vector():
	return direction * magnitude
	
func get_actual_vector():
	return direction * magnitude * 10
	
	
func set_vector(value):
	var vector_end  = value
	direction       = vector_end.normalized()
	magnitude       = vector_end.length()
	set_labels()
	queue_redraw()
	
func set_labels():
	if !Engine.is_editor_hint():
		$value.size     = Vector2(0, 0)
		$magnitude.size = Vector2(0, 0)
		$magnitude.text = str("%4.1f" % (magnitude) )
		$value.text     = str("%4.1f" % (get_vector().x) + "\n" + "%4.1f" % (get_vector().y) )
	
		$magnitude.position = get_actual_vector() * 0.5
		$value.position     = get_actual_vector() + Vector2(5,5)
	
func update_vector_width(value):
	vector_width = value
	queue_redraw()
	
func update_vector_color(value):
	vector_color = value
	queue_redraw()
	
func set_magnitude(value):
	set_vector(direction * value)
	
func _draw():
	draw_vector( Vector2( 0, 0 ), direction * magnitude*10 , vector_color, vector_width )

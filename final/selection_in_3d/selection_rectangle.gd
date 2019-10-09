extends Node2D

var selection_from = Vector2()
var selection_size = Vector2()
	
func draw_selection(from, to):
	selection_from = from
	selection_size = to - from
	update()

func _draw():
	draw_rect( Rect2( selection_from, selection_size), Color(1,1,1,0.1), true )
	draw_rect( Rect2( selection_from, selection_size), Color(1,1,1,0.3), false )

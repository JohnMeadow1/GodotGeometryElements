extends Node2D

func _process( delta ):
	process_input( delta )
	update()

func process_input( delta ):
	
	if Input.is_action_pressed("ui_up"):
		$body/AnimationPlayer.play("thrust")
		
	if Input.is_action_pressed("ui_down"):
		$body/AnimationPlayer.play("thrust")

	if Input.is_action_pressed("ui_left"):
		pass
	if Input.is_action_pressed("ui_right"):
		pass

func _draw():
	pass

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
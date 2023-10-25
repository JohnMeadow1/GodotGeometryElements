extends Node2D
var vector_W = Vector2( 4.0, 4.0 )
var vector_V = Vector2( 1.0, 1.0 )

var projection = Vector2( 0.0, 0.0 )


func _ready():
	projection = vector_V.dot(vector_W) / vector_V.length_squared() * vector_V
	print(projection)
	projection = vector_W.project(vector_V)
	print(projection)

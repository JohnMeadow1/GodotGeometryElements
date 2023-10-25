extends Node2D

var vector1 = null
var vector2 = null

func draw_vector( origin, vector, color, arrow_size ):
	if vector.length_squared() > 1:
		var points    = []
		var direction = vector.normalized()
		vector += origin
		vector -= direction * arrow_size*2
		points.push_back( vector + direction * arrow_size*2  )
		points.push_back( vector + direction.rotated(  PI / 1.5 ) * arrow_size * 2 )
		points.push_back( vector + direction.rotated( -PI / 1.5 ) * arrow_size * 2 )
		draw_polygon( PackedVector2Array( points ), PackedColorArray( [color] ) )
		draw_line( origin, vector, color, arrow_size )
		
func draw_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])

	for i in range(nb_points+1):
		var angle_point = angle_from + i * angle_to / nb_points
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func projection(v1:Vector2, v2:Vector2):
	v1.project(v2)
	return v1.dot( v2 ) / v1.length_squared() * v1

func swap_vectors(node):
	vector1 = vector2 
	vector2 = node

func point_at_distance_from_vector(vector_origin, vector, point, max_distance):
	var point_local_pos = point - vector_origin
	var point_to_vec_projection = projection(vector, point_local_pos)
	if point_to_vec_projection.normalized().dot(vector.normalized()) == 1:
		if point_to_vec_projection.length_squared() <= vector.length_squared():
			if (point - (vector_origin + point_to_vec_projection)).length() <= max_distance:
				return true
	return false

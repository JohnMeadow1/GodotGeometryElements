@tool
extends Node
@onready var target_geo = $Target_geo
@onready var ray_geo = $Ray_geo
@onready var target_wire = $Target_wire

var Point_1 = Vector3()
var Point_2 = Vector3()
var Point_3 = Vector3()
var Point_4 = Vector3()

var Point_T = Vector3()

var ray = Vector3()
var hit = Vector3()
var normal = Vector3()

var t   = 0.0
var a   = 0.0

var timer      = 0
var timer_step = 0.01
var is_target_hit = false

func _ready():
#	target_geo.mesh.rotation_degrees = Vector3(0.0,0.0,0.0)
#	target_wire.rotation_degrees = Vector3(0.0,0.0,0.0)
	$Source.position = Vector3(0,0,9)
	generate_geometry()
	generate_geometry_wireframe()

func _process(delta):
	timer += delta
	if ( timer >= 2 ):
		timer_step *= -1
		timer = 0

	rotate_geometry( delta )
	$Source.position +=  Vector3( timer_step, 0, 0 )

	ray = $Ray.position - $Source.position
	is_target_hit = false

	ray_geo.material_override.set("albedo_color", Color( 1, 0, 0 ) )
	$Hit.material_override.set("albedo_color", Color( 1, 0, 0 ) )

	# test each triangle
	is_target_hit = test_triangle_hit(Point_1,Point_2,Point_3)
	is_target_hit = test_triangle_hit(Point_4,Point_3,Point_1) or is_target_hit
	$Hit.position = hit

	update_ray()

func test_triangle_hit( P1, P2, P3 ):
	var source = $Source.position
	var surface_normal = ( P2 - P1 ).cross( P3 - P1 ).normalized()
	a = -surface_normal.dot(P1)
	if surface_normal.dot( ray ) !=0:
		t = -( surface_normal.dot( source ) + a ) / ( surface_normal.dot( ray ) )
		Point_T = source + t * ray
#		if ngon_check(Point_T, P1, P2, P3, surface_normal ):
		if triangle_check(Point_T, P1, P2, P3, surface_normal):
			$Hit.material_override.set("albedo_color", Color( 0, 1, 0 ) )
			ray_geo.material_override.set("albedo_color", Color( 0, 1, 0 ) )
			hit    = Point_T
			normal = surface_normal
			return true
	return false

func triangle_check( PT, P1, P2, P3, surface_normal):
	var M = Transform2D()
	M.x = Vector2((P3-P1).length_squared(), -(P3-P1).dot(P2-P1))
	M.y = Vector2(-(P3-P1).dot(P2-P1), (P2-P1).length_squared())
	var M_1 = M.inverse()
	
	var V = Vector2()
	V.x = (PT-P1).dot(P2-P1)
	V.y = (PT-P1).dot(P3-P1)
	
	var O = M_1 * V / (( P2 - P1 ).cross( P3 - P1 )).length_squared()
	print (O.x, ", ", O.y, ", ",O.x+O.y )
	if O.x >=0.0 && O.y >=0.0 && O.x+O.y <= 1.0:
		return true
	return false

func ngon_check( PT, P1, P2, P3, surface_normal ):
	if ( (P2 - P1).cross(PT - P1) ).dot(surface_normal) > 0:
		if ( (P3 - P2).cross(PT - P2) ).dot(surface_normal) > 0:
			if ( (P1 - P3).cross(PT - P3) ).dot(surface_normal) > 0:
				return true
	return false

func calculate_ray_reflection():
	return ( ray - 2 * ( ray ).dot( normal ) * normal )

func rotate_geometry( angle ):
	$Target_geometry.rotate_y( angle )
	Point_1 = Point_1.rotated(Vector3(0,1,0), angle)
	Point_2 = Point_2.rotated(Vector3(0,1,0), angle)
	Point_3 = Point_3.rotated(Vector3(0,1,0), angle)
	Point_4 = Point_4.rotated(Vector3(0,1,0), angle)
	
	target_wire.rotate_y( angle )

func update_ray():
	ray_geo.clear()
	ray_geo.begin( RenderingServer.PRIMITIVE_LINE_STRIP, null )
	ray_geo.add_vertex( $Source.position )
	if is_target_hit:
		ray_geo.add_vertex( hit )
		ray_geo.add_vertex( $Hit.position + calculate_ray_reflection() * 1000 )
	else:
		ray_geo.add_vertex( ($Ray.position-$Source.position)  * 1000 )
	ray_geo.end()

func generate_geometry():
	# initialize points
	Point_1 = Vector3( -2, -2, 0 )
	Point_2 = Vector3(  2, -2, 0 )
	Point_3 = Vector3(  2,  2, 0 )
	Point_4 = Vector3( -2,  2, 0 ).rotated( Vector3( 1, 0, 0 ), 1 )
	
	target_geo.mesh.begin( RenderingServer.PRIMITIVE_TRIANGLES, null )
	
	# first triangle
	target_geo.mesh.set_normal( (Point_3-Point_2).cross(Point_1-Point_2).normalized() )
	target_geo.mesh.set_uv( Vector2( 0, 1 ) )
	target_geo.mesh.add_vertex( Point_1 )
	target_geo.mesh.set_uv( Vector2( 1, 0 ) )
	target_geo.mesh.add_vertex( Point_3 )
	target_geo.mesh.set_uv( Vector2( 1, 1 ) )
	target_geo.mesh.add_vertex( Point_2 )
	# second triangle
	target_geo.mesh.set_normal( (Point_1-Point_4).cross(Point_3-Point_4).normalized() )
	target_geo.mesh.set_uv( Vector2( 0, 1 ) )
	target_geo.mesh.add_vertex( Point_1 )
	target_geo.mesh.set_uv( Vector2( 0, 0 ) )
	target_geo.mesh.add_vertex( Point_4 )
	target_geo.mesh.set_uv( Vector2( 1, 0 ) )
	target_geo.mesh.add_vertex( Point_3 )

	target_geo.mesh.end()
	
func generate_geometry_wireframe():
	target_wire.begin( RenderingServer.PRIMITIVE_LINE_STRIP, null )
	target_wire.add_vertex( Point_1 )
	target_wire.add_vertex( Point_2 )
	target_wire.add_vertex( Point_3 )
	target_wire.add_vertex( Point_1 )
	target_wire.add_vertex( Point_4 )
	target_wire.add_vertex( Point_3 )
	target_wire.end()


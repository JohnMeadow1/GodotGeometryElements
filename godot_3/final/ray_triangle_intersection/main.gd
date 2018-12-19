tool
extends Node

var P1 = Vector3()
var P2 = Vector3()
var P3 = Vector3()
var P4 = Vector3()

var ray = Vector3()
var hit = Vector3()
var normal = Vector3()

var t   = 0.0
var a   = 0.0

var timer      = 0
var timer_step = 0.01
var is_target_hit = false

func _ready():
	$Target_geometry.rotation_degrees = Vector3(0.0,0.0,0.0)
	$Target_wireframe.rotation_degrees = Vector3(0.0,0.0,0.0)
#	$Source.translation = Vector3(0,0,9)
	generate_geometry()
	generate_geometry_wireframe()

func _process(delta):
	timer += delta
	if ( timer >= 2 ):
		timer_step *= -1
		timer = 0

	rotate_geometry( delta )
	$Source.translation +=  Vector3( timer_step, 0, 0 )

	ray = $Ray.translation - $Source.translation
	is_target_hit = false

	$Ray_geometry.material_override.set("albedo_color", Color( 1, 0, 0 ) )
	$Hit.material_override.set("albedo_color", Color( 1, 0, 0 ) )

	# test each triangle
	is_target_hit = test_triangle_hit(P1,P2,P3)
	is_target_hit = test_triangle_hit(P4,P3,P1) or is_target_hit
	$Hit.translation = hit

	update_ray()

func test_triangle_hit( P1, P2, P3 ):
	var source = $Source.translation
	var surface_normal = ( P2 - P1 ).cross( P3 - P1 ).normalized()
	a = -surface_normal.dot(P1)
	if surface_normal.dot( ray ) !=0:
		t = -( surface_normal.dot( source ) + a ) / ( surface_normal.dot( ray ) )
		var surface_hit = source + t * ray
		if ( (P2 - P1).cross(surface_hit - P1) ).dot(surface_normal) > 0:
			if ( (P3 - P2).cross(surface_hit - P2) ).dot(surface_normal) > 0:
				if ( (P1 - P3).cross(surface_hit - P3) ).dot(surface_normal) > 0:
					$Hit.material_override.set("albedo_color", Color( 0, 1, 0 ) )
					$Ray_geometry.material_override.set("albedo_color", Color( 0, 1, 0 ) )
					hit    = surface_hit
					normal = surface_normal
					return true
	return false
	
func calculate_ray_reflection():
	return ( ray - 2 * ( ray ).dot( normal ) * normal )
	
func rotate_geometry( angle ):
	$Target_geometry.rotate_y( angle )
	P1 = P1.rotated(Vector3(0,1,0), angle)
	P2 = P2.rotated(Vector3(0,1,0), angle)
	P3 = P3.rotated(Vector3(0,1,0), angle)
	P4 = P4.rotated(Vector3(0,1,0), angle)
	
	$Target_wireframe.rotate_y( angle )

func update_ray():
	$Ray_geometry.clear()
	$Ray_geometry.begin( VisualServer.PRIMITIVE_LINE_STRIP, null )
	$Ray_geometry.add_vertex( $Source.translation )
	if is_target_hit:
		$Ray_geometry.add_vertex( hit )
		$Ray_geometry.add_vertex( $Hit.translation + calculate_ray_reflection() * 1000 )
	else:
		$Ray_geometry.add_vertex( ($Ray.translation-$Source.translation)  * 1000 )
	$Ray_geometry.end()

func generate_geometry():
	# initialize points
	P1 = Vector3( -2, -2, 0 )
	P2 = Vector3(  2, -2, 0 )
	P3 = Vector3(  2,  2, 0 )
	P4 = Vector3( -2,  2, 0 ).rotated( Vector3( 1, 0, 0 ), 1 )
	
	$Target_geometry.begin( VisualServer.PRIMITIVE_TRIANGLES, null )
	
	# first triangle
	$Target_geometry.set_normal( (P3-P2).cross(P1-P2).normalized() )
	$Target_geometry.set_uv( Vector2( 0, 1 ) )
	$Target_geometry.add_vertex( P1 )
	$Target_geometry.set_uv( Vector2( 1, 0 ) )
	$Target_geometry.add_vertex( P3 )
	$Target_geometry.set_uv( Vector2( 1, 1 ) )
	$Target_geometry.add_vertex( P2 )
	# second triangle
	$Target_geometry.set_normal( (P1-P4).cross(P3-P4).normalized() )
	$Target_geometry.set_uv( Vector2( 0, 1 ) )
	$Target_geometry.add_vertex( P1 )
	$Target_geometry.set_uv( Vector2( 0, 0 ) )
	$Target_geometry.add_vertex( P4 )
	$Target_geometry.set_uv( Vector2( 1, 0 ) )
	$Target_geometry.add_vertex( P3 )

	$Target_geometry.end()
	
func generate_geometry_wireframe():
	$Target_wireframe.begin( VisualServer.PRIMITIVE_LINE_STRIP, null )
	$Target_wireframe.add_vertex( P1 )
	$Target_wireframe.add_vertex( P2 )
	$Target_wireframe.add_vertex( P3 )
	$Target_wireframe.add_vertex( P1 )
	$Target_wireframe.add_vertex( P4 )
	$Target_wireframe.add_vertex( P3 )
	$Target_wireframe.end()


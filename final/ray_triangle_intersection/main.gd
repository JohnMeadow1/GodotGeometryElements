extends Node

onready var Source  = get_node("Source").get_translation()
var Ray  = Vector3()

var P1 = Vector3()
var P2 = Vector3()
var P3 = Vector3()
var P4 = Vector3()

var Normal   = Vector3()
var Hit = Vector3()

var t   = 0.0
var a   = 0.0

var timer      = 0
var timer_step = 0.01
var target_is_hit = false

func _ready():
	set_fixed_process(true)
	generate_geometry()
	generate_geometry_wireframe()

func _fixed_process(delta):
	timer += delta
	if ( timer >= 2 ):
		timer_step *= -1
		timer = 0

	rotate_geometry( delta )

	get_node("Source").set_translation( Source + Vector3( timer_step, 0, 0 ) )
	Source = get_node("Source").get_translation()

	Ray = get_node("Ray").get_translation() - Source
	target_is_hit = false

	get_node("Ray_geometry").get_material_override().set_parameter( 0, Color( 1, 0, 0 ) )
	get_node("Hit"         ).get_material_override().set_parameter( 0, Color( 1, 0, 0 ) )

	# test each triangle
	target_is_hit = test_triangle_hit(P1,P2,P3)
	target_is_hit = test_triangle_hit(P4,P3,P1) or target_is_hit
	get_node("Hit").set_translation( Hit )

	update_ray()

func test_triangle_hit(P1,P2,P3):
	var surface_Normal = ( P2 - P1 ).cross( P3 - P1 ).normalized()
	a = -surface_Normal.dot(P1)
	t = -( surface_Normal.dot(Source) + a ) / ( surface_Normal.dot(Ray) )
	var surface_Hit = Source + t * Ray
	if ( (P2 - P1).cross(surface_Hit - P1) ).dot(surface_Normal) > 0:
		if ( (P3 - P2).cross(surface_Hit - P2) ).dot(surface_Normal) > 0:
			if ( (P1 - P3).cross(surface_Hit - P3) ).dot(surface_Normal) > 0:
				get_node("Hit"         ).get_material_override().set_parameter( 0, Color( 0, 1, 0 ) )
				get_node("Ray_geometry").get_material_override().set_parameter( 0, Color( 0, 1, 0 ) )
				Hit    = surface_Hit
				Normal = surface_Normal
				return true
	return false

func rotate_geometry( angle ):
	var target_geo = get_node( "Target_geometry" )
	target_geo.rotate_y( angle )
	P1 = P1.rotated(Vector3(0,1,0), angle)
	P2 = P2.rotated(Vector3(0,1,0), angle)
	P3 = P3.rotated(Vector3(0,1,0), angle)
	P4 = P4.rotated(Vector3(0,1,0), angle)
	
	var wireframe_geo = get_node( "Target_wireframe" )
	wireframe_geo.rotate_y( angle )

func update_ray():
	var ray_geo = get_node("Ray_geometry")
	ray_geo.clear()
	ray_geo.begin( VS.PRIMITIVE_LINE_STRIP, null )
	ray_geo.add_vertex( Source )
	if target_is_hit:
		ray_geo.add_vertex( Hit )
		var reflection = ( Ray - 2 * ( Ray ).dot( Normal ) * Normal ) * 1000
		ray_geo.add_vertex( Hit + reflection )
	else:
		ray_geo.add_vertex( Source + Ray * 1000 )
	ray_geo.end()

func generate_geometry():
	# initialize points
	P1 = Vector3( -2, -2, 0 )
	P2 = Vector3(  2, -2, 0 )
	P3 = Vector3(  2,  2, 0 )
	P4 = Vector3( -2,  2, 0 ).rotated( Vector3( 1, 0, 0 ), 1 )
	
	var target_geo = get_node( "Target_geometry" )
	target_geo.begin( VS.PRIMITIVE_TRIANGLES, null )
	
	# first triangle
	target_geo.set_normal( (P3-P2).cross(P1-P2).normalized() )
	target_geo.set_uv( Vector2( 0, 1 ) )
	target_geo.add_vertex( P1 )
	target_geo.set_uv( Vector2( 1, 0 ) )
	target_geo.add_vertex( P3 )
	target_geo.set_uv( Vector2( 1, 1 ) )
	target_geo.add_vertex( P2 )
	# second triangle
	target_geo.set_normal( (P1-P4).cross(P3-P4).normalized() )
	target_geo.set_uv( Vector2( 0, 1 ) )
	target_geo.add_vertex( P1 )
	target_geo.set_uv( Vector2( 0, 0 ) )
	target_geo.add_vertex( P4 )
	target_geo.set_uv( Vector2( 1, 0 ) )
	target_geo.add_vertex( P3 )

	target_geo.end()
	
func generate_geometry_wireframe():
	var wireframe_geo = get_node("Target_wireframe")
	wireframe_geo.begin( VS.PRIMITIVE_LINE_STRIP, null )
	wireframe_geo.add_vertex( P1 )
	wireframe_geo.add_vertex( P2 )
	wireframe_geo.add_vertex( P3 )
	wireframe_geo.add_vertex( P1 )
	wireframe_geo.add_vertex( P4 )
	wireframe_geo.add_vertex( P3 )
	wireframe_geo.end()

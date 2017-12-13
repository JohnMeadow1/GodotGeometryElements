extends Node

var Source  = Vector3()
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
	
func _fixed_process(delta):
	timer += delta
	if ( timer >= 2 ):
		timer_step *= -1
		timer = 0

	Source = get_node("Source").get_translation()
	get_node("Source").set_translation( Source + Vector3( timer_step, 0, 0 ) )
	Ray = get_node("Ray").get_translation() - Source
	Normal = ( P2 - P1 ).cross( P4 - P1 ).normalized()
	a = -Normal.dot(P1)
	t = -( Normal.dot(Source) + a ) / ( Normal.dot(Ray) )
	Hit = Source + t * Ray 

	target_is_hit = false
	get_node("Hit").set_translation( Hit )
	get_node("Hit").get_material_override().set_parameter( 0, Color( 1, 0, 0 ) )
	get_node("Ray_geometry").get_material_override().set_parameter( 0, Color( 1, 0, 0 ) )
	# test each quad edge
	if ( (P2 - P1).cross(Hit - P1) ).dot(Normal) > 0:
		if ( (P3 - P2).cross(Hit - P2) ).dot(Normal) > 0:
			if ( (P4 - P3).cross(Hit - P3) ).dot(Normal) > 0:
				if ( (P1 - P4).cross(Hit - P4) ).dot(Normal) > 0:
					get_node("Hit").get_material_override().set_parameter( 0, Color( 0, 1, 0 ) )
					get_node("Ray_geometry").get_material_override().set_parameter( 0, Color( 0, 1, 0 ) )
					target_is_hit = true
	update_ray()

func generate_geometry():
	P4 = Vector3( -2,  2, 0 ).rotated( Vector3( 1, 0, 0 ), 0.6 )
	P3 = Vector3(  2,  2, 0 ).rotated( Vector3( 1, 0, 0 ), 0.6 )
	P2 = Vector3(  2, -2, 0 ).rotated( Vector3( 1, 0, 0 ), 0.6 )
	P1 = Vector3( -2, -2, 0 ).rotated( Vector3( 1, 0, 0 ), 0.6 )

	var target_geo = get_node( "Target_geometry" )
	target_geo.begin( VS.PRIMITIVE_TRIANGLES, null )
	target_geo.set_normal( Vector3( 0, 0, 1 ).rotated( Vector3( 1, 0, 0 ), 0.6 ) )
	# first triangle
	target_geo.set_uv( Vector2( 1, 1 ) )
	target_geo.add_vertex( P3 )
	target_geo.set_uv( Vector2( 1, 0 ) )
	target_geo.add_vertex( P2 )
	target_geo.set_uv( Vector2( 0, 0 ) )
	target_geo.add_vertex( P1 )
	# second triangle
	target_geo.set_uv( Vector2( 1, 0 ) )
	target_geo.add_vertex( P4 )
	target_geo.set_uv( Vector2( 1, 1 ) )
	target_geo.add_vertex( P3 )
	target_geo.set_uv( Vector2( 0, 0 ) )
	target_geo.add_vertex( P1 )

	target_geo.end()
	target_geo.set_material_override( load("res://target_material.tres") )

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

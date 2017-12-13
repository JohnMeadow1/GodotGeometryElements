extends Node

var Source  = Vector3()
var Ray     = Vector3()

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


	target_is_hit = false
	get_node("Hit").set_translation( Hit )
	get_node("Hit").get_material_override().set_parameter( 0, Color( 1, 0, 0 ) )
	get_node("Ray_geometry").get_material_override().set_parameter( 0, Color( 1, 0, 0 ) )
	# test each quad edge

	update_ray()

func generate_geometry():
	P4 = Vector3( 0, 0, 0 )
	P3 = Vector3( 0, 0, 0 )
	P2 = Vector3( 0, 0, 0 )
	P1 = Vector3( 0, 0, 0 )

	var target_geo = get_node( "Target_geometry" )
	target_geo.begin( VS.PRIMITIVE_TRIANGLES, null )

	target_geo.end()
	target_geo.set_material_override( load("res://target_material.tres") )

func update_ray():
	var ray_geo = get_node("Ray_geometry")
	ray_geo.clear()
	ray_geo.begin( VS.PRIMITIVE_LINE_STRIP, null )
	ray_geo.add_vertex( Source )
	if target_is_hit:
		ray_geo.add_vertex( Hit )
	else:
		ray_geo.add_vertex( Source + Ray * 1000 )
	ray_geo.end()

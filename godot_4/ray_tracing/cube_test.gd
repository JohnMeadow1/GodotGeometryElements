@tool
extends Node

@export var abc := Vector3(1.0,1.0,1.0) : set = set_cube_size
var center := Vector3()
var a := 0.0
var b := 0.0
var c := 0.0

var source := Vector3()
var ray    := Vector3()

var source_at_object := Vector3()
var ray_at_object    := Vector3()

var t       := 0.0
var Point_T := Vector3()

var hit_position := Vector3()
var normal       := Vector3()

var is_target_hit := false
var timer := 0.0
func _ready():
#	$Source.position = Vector3(0,0,9)
	a = abc.x
	b = abc.y
	c = abc.z
	
func _process(_delta):
	timer += _delta
#	rotate_geometry(_delta*0.1)
	is_target_hit = false
#	$Cube.position.y = sin(timer)
	$Ray_geometry.material_override.set("albedo_color", Color.RED )
	$Hit.material_override.set("albedo_color", Color.RED )
	center = $Cube.position
	source = $Source.position
	ray    = $Ray.position - $Source.position
	
	source_at_object = $Cube.transform.basis.inverse() * (source - center)
	ray_at_object    = $Cube.transform.basis.inverse() * ray
	
	is_target_hit = test_cube_hit()
	
	if is_target_hit:
		hit_position = $Cube.transform.basis * Point_T + center
		normal = $Cube.transform.basis * normal
		
		$Hit.position = hit_position
		$Ray_geometry.material_override.set("albedo_color", Color.GREEN )
		$Hit.material_override.set("albedo_color", Color.GREEN )

	update_ray()

func test_cube_hit():
	if abs(ray_at_object.x) > 0:
		t = - (source_at_object.x + sign(ray_at_object.x) * a * 0.5)
		t /= ray_at_object.x
		Point_T.x = -sign(ray_at_object.x) * a * 0.5
		Point_T.y = source_at_object.y + t * ray_at_object.y
		Point_T.z = source_at_object.z + t * ray_at_object.z
		if -b*0.5 < Point_T.y &&  Point_T.y < b*0.5:
			if -c*0.5 < Point_T.z && Point_T.z < c*0.5:
				normal = Vector3(sign(ray_at_object.x),0,0)
				return true
		
	if abs(ray_at_object.y) > 0:
		t = - (source_at_object.y + sign(ray_at_object.y) * b * 0.5)
		t /= ray_at_object.y
		Point_T.x = source_at_object.x + t * ray_at_object.x
		Point_T.y = -sign(ray_at_object.y) * b * 0.5
		Point_T.z = source_at_object.z + t * ray_at_object.z
		if -a*0.5 < Point_T.x &&  Point_T.x < a*0.5:
			if -c*0.5 < Point_T.z && Point_T.z < c*0.5:
				normal = Vector3(0, sign(ray_at_object.y),0)
				return true
				
	if abs(ray_at_object.z) > 0:
		t = - (source_at_object.z + sign(ray_at_object.z) * c * 0.5)
		t /= ray_at_object.z
		Point_T.x = source_at_object.x + t * ray_at_object.x
		Point_T.y = source_at_object.y + t * ray_at_object.y
		Point_T.z = -sign(ray_at_object.z) * c * 0.5
		if -a*0.5 < Point_T.x &&  Point_T.x < a*0.5:
			if -b*0.5 < Point_T.y && Point_T.y < b*0.5:
				normal = Vector3(0, 0, sign(ray_at_object.z))
				return true
	return false

func calculate_ray_reflection():
	return ( ray - 2 * ( ray ).dot( normal ) * normal )

func rotate_geometry( angle ):
	$Cube.rotate_x( angle )
	$Cube.rotate_y( angle*2 )
#	$Cube.rotate_z( angle )

func update_ray():
	$Ray_geometry.clear()
	$Ray_geometry.begin( RenderingServer.PRIMITIVE_LINE_STRIP, null )
	$Ray_geometry.add_vertex( $Source.position )
	if is_target_hit:
		$Ray_geometry.add_vertex( $Hit.position )
		$Ray_geometry.add_vertex( $Hit.position + calculate_ray_reflection() * 1000 )
	else:
		$Ray_geometry.add_vertex( ($Ray.position-$Source.position)  * 1000 )
	$Ray_geometry.end()
	
func set_cube_size(value):
	abc = value
	a = abc.x
	b = abc.y
	c = abc.z
	if Engine.is_editor_hint():
		$Cube.mesh.size = abc


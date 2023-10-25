@tool
extends Node
@export var radius := 1.0 : set = set_sphere_size
var center := Vector3()

var source := Vector3()
var ray    := Vector3()
var source_at_object := Vector3()
var ray_at_object    := Vector3()

var delta   := 0.0
var t       := 0.0
var Point_T := Vector3()

var hit_position := Vector3()
var normal       := Vector3()

var is_target_hit := false

var timer := 0.0

func _ready():
	$Source.position = Vector3(0,0,9)
	
func _process(_delta):
	timer += _delta
	rotate_geometry( _delta )
	$Sphere.position.y = sin(timer)
	$Sphere.position.x = cos(timer)
	center = $Sphere.position
	
	ray = $Ray.position - $Source.position
	ray_at_object = $Sphere.transform.basis.inverse() * ray
	
	source = $Source.position
	source_at_object = $Sphere.transform.basis.inverse() * (source - center)
	
	is_target_hit = false
	$Ray_geometry.material_override.set("albedo_color", Color.RED )
	$Hit.material_override.set("albedo_color", Color.RED )
	is_target_hit = test_sphere_hit()
	
	if is_target_hit:
		hit_position = $Sphere.transform.basis * Point_T + center
		$Hit.position = hit_position
		$Ray_geometry.material_override.set("albedo_color", Color.GREEN )
		$Hit.material_override.set("albedo_color", Color.GREEN )
		normal = ($Sphere.transform.basis * Point_T).normalized()
	update_ray()

func test_sphere_hit():
	delta = 4.0 * ray_at_object.length_squared() * pow(radius, 2)
	delta -= 4.0 * source_at_object.cross(ray_at_object).length_squared() 
	
	t = -source_at_object.dot(ray_at_object)
	t -= sqrt( ray_at_object.length_squared() * pow(radius, 2) - source_at_object.cross(ray_at_object).length_squared() )
	t /= ray_at_object.length_squared()
	
	if source_at_object.dot(ray_at_object) && t>=0:
		Point_T = source_at_object + t * ray_at_object
		return true
	return false

func calculate_ray_reflection():
	return ( ray - 2 * ( ray ).dot( normal ) * normal )

func rotate_geometry( angle ):
	$Sphere.rotate_y( angle )
	$Sphere.rotate_x( angle*2 )

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
	
func set_sphere_size(value):
	radius = value
	if Engine.is_editor_hint():
		$Sphere.mesh.radius = radius
		$Sphere.mesh.height = radius * 2

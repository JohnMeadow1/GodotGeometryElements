extends Camera3D

var camera_position           = Vector3(0,-40,0)
var camera_target             = Vector3(0,0,0)
var camera_up_vector          = Vector3(0,1,0)
var mouse_pressed = false
var ignore_mouse  = false
var camera_distance_to_center = 50

var yaw         = 0
var pitch       = 25

var sensitivity = 0.05
var scoll_speed = 5
var target_id   = 0

#func _ready():
#	set_as_toplevel(true)

func _physics_process( delta ):
	camera_target = $"../Cube/Lajkonik".transform.origin

	var x = camera_distance_to_center * sin(deg_to_rad(yaw)) * cos(deg_to_rad(pitch))
	var y = camera_distance_to_center * sin(deg_to_rad(pitch))
	var z = camera_distance_to_center * cos(deg_to_rad(yaw)) * cos(deg_to_rad(pitch))

	look_at_from_position( camera_target + Vector3 ( x, y, z ), camera_target, camera_up_vector )

func _input(event):
	
	if event is InputEventMouseMotion and mouse_pressed:
		yaw     += event.relative.x * sensitivity
		pitch    = clamp ( pitch + event.relative.y * sensitivity,-80,80)
		
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1 and !ignore_mouse:
			mouse_pressed = true
			Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
			
		if !event.pressed and event.button_index == 1:
			mouse_pressed = false
			if ignore_mouse:
				ignore_mouse = false
			else:
				Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
			
		if event.pressed and event.button_index == 4:
			camera_distance_to_center = clamp( camera_distance_to_center - scoll_speed, 4, 400)

		if event.pressed and event.button_index == 5:
			camera_distance_to_center = clamp( camera_distance_to_center + scoll_speed, 4, 400)

		
func get_new_target(id):
	var max_target = get_parent().get_node("boids").get_child_count()
	target_id += id 
	if ( target_id < 0 ):
		target_id = max_target-1
	target_id %= max_target
#	get_parent().get_node("boids").get_child(target_id).material_override.set("albedo_color", Color(1,0,0))extends Camera

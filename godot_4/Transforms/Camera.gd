extends Camera3D

var camera_position           = Vector3(0,-40,0)
var camera_target             = Vector3(0,0,0)
var camera_up_vector          = Vector3(0,1,0)
var mouse_LMB_pressed = false
var mouse_RMB_pressed = false
var ignore_mouse  = false
var camera_distance_to_center = 50

var yaw         = 0
var pitch       = 25

var sensitivity = 0.05
var scoll_speed = 5
var target_id   = 0

func _ready():
	camera_target = $"../Cube/Lajkonik".transform.origin

func _physics_process( delta ):
	var x = camera_distance_to_center * sin(deg_to_rad(yaw)) * cos(deg_to_rad(pitch))
	var y = camera_distance_to_center * sin(deg_to_rad(pitch))
	var z = camera_distance_to_center * cos(deg_to_rad(yaw)) * cos(deg_to_rad(pitch))

	look_at_from_position( camera_target + Vector3 ( x, y, z ), camera_target, camera_up_vector )

func _input(event):
	
	if event is InputEventMouseMotion:
		if mouse_LMB_pressed:
			yaw     -= event.relative.x * sensitivity
			pitch    = clamp ( pitch + event.relative.y * sensitivity,-80,80)
		if mouse_RMB_pressed:
			camera_target -= Vector3(event.relative.x, 0, event.relative.y).rotated(Vector3.UP,rotation.y) * sensitivity
		
	if event is InputEventMouseButton:
		if event.pressed: 
			if event.button_index == MOUSE_BUTTON_LEFT and !ignore_mouse:
				mouse_LMB_pressed = true
			if event.button_index == MOUSE_BUTTON_RIGHT and !ignore_mouse:
				mouse_RMB_pressed = true
			Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
			
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				mouse_LMB_pressed = false
			if event.button_index == MOUSE_BUTTON_RIGHT:
				mouse_RMB_pressed = false
			if ignore_mouse:
				ignore_mouse = false
			else:
				Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
			
			
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance_to_center = clamp( camera_distance_to_center - scoll_speed, 4, 400)

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance_to_center = clamp( camera_distance_to_center + scoll_speed, 4, 400)

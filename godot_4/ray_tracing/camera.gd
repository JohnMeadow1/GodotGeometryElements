
extends Camera3D

var camera_position           = Vector3(0,0,0)
var camera_target             = Vector3(0,0,0)
var camera_up_vector          = Vector3(0,1,0)

var camera_distance_to_center = 5

var yaw         = 0
var pitch       = 25

var sensitivity = 0.15
var scoll_speed = 2
var mouse_button_down = false

func _ready():
#	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	pass
	
func _physics_process(dt):
	var x = camera_distance_to_center * sin(deg_to_rad(yaw)) * cos(deg_to_rad(pitch))
	var y = camera_distance_to_center * sin(deg_to_rad(pitch))
	var z = camera_distance_to_center * cos(deg_to_rad(yaw)) * cos(deg_to_rad(pitch))

	look_at_from_position( Vector3 ( x, y, z ), camera_target, camera_up_vector )

func _input(event):
	if (event is InputEventMouseButton):
		mouse_button_down = false
		if (event.pressed and event.button_index == 1):
			mouse_button_down = true
		if (event.pressed and event.button_index == 4):
			camera_distance_to_center = clamp( camera_distance_to_center - scoll_speed, 4, 400)

		if (event.pressed and event.button_index == 5):
			camera_distance_to_center = clamp( camera_distance_to_center + scoll_speed, 4, 400)

	if ( event is InputEventMouseMotion && mouse_button_down ):
		yaw     -= event.relative.x * sensitivity
		pitch    = clamp ( pitch + event.relative.y * sensitivity,-80,80)
		

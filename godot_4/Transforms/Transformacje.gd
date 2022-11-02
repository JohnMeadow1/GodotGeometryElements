#tool
extends Node3D

func _process(delta):
#	print ($pyramid.transform)
	
	var transform = $Cube.transform * $Cube/Lajkonik.transform * $Cube/Lajkonik/hand.transform
#	print (transform)
	$pyramid.transform = transform

	
#	$pyramid.transform = $Cube/Lajkonik/hand.global_transform
	
	
#	print ( transform )
	pass

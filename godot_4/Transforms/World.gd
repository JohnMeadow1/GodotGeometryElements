extends Node3D

@onready var cube := $Cube as Node3D
@onready var lajkonik := $Cube/Lajkonik as Node3D
@onready var hand := $Cube/Lajkonik/hand as Node3D

func _ready():
	print ($pyramid.transform.origin)
	var transpose = $pyramid.transform.basis.transposed()
	print (transpose.x)
	print (transpose.y)
	print (transpose.z)

#	var target_transform = cube.transform * lajkonik.transform * hand.transform
#	$pyramid.transform = target_transform

func _physics_process(delta):
#	var target_basis = cube.transform.basis * lajkonik.transform.basis * hand.transform.basis
#	$pyramid.transform.basis = target_basis

	var target_transform = cube.transform * lajkonik.transform * hand.transform
#	$pyramid.transform = target_transform
	$pyramid.transform = hand.global_transform

extends Node3D

@onready var cube := $Cube as Node3D
@onready var lajkonik := $Cube/Lajkonik as Node3D
@onready var hand := $Cube/Lajkonik/hand as Node3D

func _ready():
	print ($pyramid.transform.origin)
	print ($pyramid.transform.basis.x)
	print ($pyramid.transform.basis.y)
	print ($pyramid.transform.basis.z)

#	var target_transform = cube.transform * lajkonik.transform * hand.transform
#	$pyramid.transform = target_transform

func _physics_process(delta):
	var target_basis= cube.transform.basis * lajkonik.transform.basis * hand.transform.basis
	$pyramid.transform.basis = target_basis

	var target_transform = cube.transform * lajkonik.transform* hand.transform
	$pyramid.transform = target_transform

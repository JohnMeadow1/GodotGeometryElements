extends MeshInstance3D

var timer := 0.0
@onready var label_3d = $Label3D

func _physics_process(delta):
	timer += delta
#	scale.z = abs(sin(timer))
	$Lajkonik.rotation.y += 0.01
	label_3d.text = str("|%2.2f, %2.2f, %2.2f"% [ $Lajkonik.transform.basis.x.x, $Lajkonik.transform.basis.x.y, $Lajkonik.transform.basis.x.z],"|")
	label_3d.text += str("\n|%2.2f, %2.2f, %2.2f"% [ $Lajkonik.transform.basis.y.x, $Lajkonik.transform.basis.y.y, $Lajkonik.transform.basis.y.z],"|")
	label_3d.text += str("\n|%2.2f, %2.2f, %2.2f"% [ $Lajkonik.transform.basis.z.x, $Lajkonik.transform.basis.z.y, $Lajkonik.transform.basis.z.z],"|")
	label_3d.text += str("\n\n|%2.2f, %2.2f, %2.2f"% [ $Lajkonik.transform.origin.x, $Lajkonik.transform.origin.y, $Lajkonik.transform.origin.z],"|")

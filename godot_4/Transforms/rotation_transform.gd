extends MeshInstance3D

var timer := 0.0
@onready var label_3d = $"../Label3D"

func _physics_process(delta):
	timer += delta
	scale.z = abs(sin(timer))
	rotation.y += 0.01
	label_3d.text = str("|%2.2f, %2.2f, %2.2f"% [ transform.basis.x.x, transform.basis.x.y, transform.basis.x.z],"|")
	label_3d.text += str("\n|%2.2f, %2.2f, %2.2f"% [ transform.basis.y.x, transform.basis.y.y, transform.basis.y.z],"|")
	label_3d.text += str("\n|%2.2f, %2.2f, %2.2f"% [ transform.basis.z.x, transform.basis.z.y, transform.basis.z.z],"|")
	label_3d.text += str("\n\n|%2.2f, %2.2f, %2.2f"% [ transform.origin.x, transform.origin.y, transform.origin.z],"|")

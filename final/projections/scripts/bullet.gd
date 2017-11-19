extends Sprite

var velocity   = Vector2()
var vet_to_ast = Vector2()

var timer     = 0
var life_time = 5

onready var asteroid = get_node("../../Asteroid")

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	vet_to_ast =  asteroid.get_pos() - self.get_pos()
	velocity  += 1000 * vet_to_ast.normalized() / ( max( vet_to_ast.length_squared(), 500 ) )
	set_pos( get_pos() + velocity )

	timer = timer + delta
	if ( timer > life_time ):
		queue_free()

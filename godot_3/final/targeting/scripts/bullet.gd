
extends Sprite

var velocity = Vector2( 0.0, 0.0 )
var timer    = 0.0
var asteroid = Vector2( 0.0, 0.0 )
var gravity  = Vector2( 0.0, 0.0 )
var target   = Vector2( 0.0, 0.0 )
var id       = 0.0

onready var player   = $"../../Spaceship"

func _ready():
	pass

func _physics_process( delta ):
	asteroid = self.position - $"../../Asteroid".position
#	velocity  += 10000/clamp(asteroid.length_squared(),40,10000)         \
#	           * -asteroid.normalized()
	position += velocity 

	timer = timer + delta
	if ( timer > 5 ):
		queue_free()

	if (id == 1):
		if ((player.position - self.position).length()<20):
			player.explosion()
			player.hp -=5
			queue_free()
	else:
		for node in $"../../rockets".get_children():
			if ( (node.position - self.position).length() < 20 && node.active == true ):
				node.destroy()
				queue_free()

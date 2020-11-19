extends RigidBody

var vel=2.5

func _ready():
	set_as_toplevel(true)
	
func lancio(dir):
	apply_central_impulse(dir*vel)

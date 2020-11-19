extends KinematicBody

onready var nav=get_node("/root/VectorNavigation")

export var vel=Vector3(0,0,0)
export var acc=Vector3(0,0,0)

export var maxTimer=2
var timer=0
var maxVel=.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	timer=timer-delta
	if timer<=0:
		acc=nav.randomizeDirection(vel,PI/2)
		vel=vel+acc
		timer=maxTimer
	if vel.length()>maxVel:
		vel=vel.normalized()*maxVel
	var _coll=move_and_collide(vel)

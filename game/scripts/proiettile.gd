extends KinematicBody

onready var burst=preload("res://Scenes/MiniBurst.tscn")

var linVel=4
var vel=Vector3(0,0,0)
var lifeSpan=150
var damage=0


func _ready():
	set_as_toplevel(true)

func setBersaglio(mask):
	set_collision_mask_bit(mask,true)	
func setDamage(d):
	damage=d
func lancio(dir):
	vel=dir.normalized()*linVel

func _physics_process(_delta):
	lifeSpan=lifeSpan-1
	if lifeSpan<0:
		queue_free()
	else:
		var coll=move_and_collide(vel)
		if coll!=null:
			var c=coll.collider
			if c.collision_layer==1 or c.collision_layer==2:
				c.takeDamage(damage)
				botto(coll.position)
			else:
				botto(global_transform.origin)

func botto(pos):
	var b=burst.instance()
	b.transform.origin=pos
	get_tree().current_scene.add_child(b)
	queue_free()

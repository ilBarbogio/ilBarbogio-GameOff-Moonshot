extends KinematicBody

onready var nav=get_node("/root/VectorNavigation")

var linVel=2
var vel=Vector3(0,0,0)
var lifeSpan=250
var damage=0
var livelliDanno=[10,25,50,100]
var lockTimer=10
var target
var trigDistance=2

onready var burst=preload("res://Scenes/MediumBurst.tscn")
onready var modBlu=get_node("razzoblu")
onready var modVerde=get_node("razzoverde")
onready var modGiallo=get_node("razzogiallo")
onready var modRosso=get_node("razzorosso")


func _ready():
	set_as_toplevel(true)

func setBersaglio(mask):
	set_collision_mask_bit(mask,true)	
func setDamage(d):
	damage=d
	if d==livelliDanno[0]:
		linVel=2
	elif d==livelliDanno[1]:
		linVel=1.5
	elif d==livelliDanno[2]:
		linVel=1
	elif d==livelliDanno[3]:
		linVel=.5
	
func lancio(dir,t):
	target=t
	vel=dir.normalized()*linVel

func _physics_process(_delta):
	lifeSpan=lifeSpan-1
	lockTimer=lockTimer-1
	if lifeSpan<=0:
		queue_free()
	elif lockTimer<=0:#lock engage
		if target!=null:
			vel=nav.directionSeekTarget(global_transform.origin,vel,target.transform.origin)
		if vel.length()<linVel:
			vel=vel.normalized()*linVel
	var coll=move_and_collide(vel)
	if coll!=null:
		var c=coll.collider
		if c.is_in_group("nemici") or c.is_in_group("player"):
			c.takeDamage(damage)
			botto(coll.position)
		elif c.collision_layer==4:
			c.spinta(transform.basis.z,damage)
			botto(coll.position)
		elif c.is_in_group("terra"):
			botto(coll.position)
		elif c.is_in_group("luna"):
			c.spinta(-global_transform.origin,damage)
			botto(coll.position)
			
func botto(pos):
	var b=burst.instance()
	b.transform.origin=pos
	get_tree().current_scene.add_child(b)
	queue_free()

func setModel(m):
	if m==0:
		modBlu.visible=true
	elif m==1:
		modVerde.visible=true
	elif m==2:
		modGiallo.visible=true
	elif m==3:
		modRosso.visible=true

func takeDamage(_d):
	pass

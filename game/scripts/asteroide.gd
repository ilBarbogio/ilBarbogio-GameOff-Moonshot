extends KinematicBody

onready var director=get_node("/root/Director")

onready var burst=preload("res://Scenes/WhiteBurst.tscn")
var rng=RandomNumberGenerator.new()
var vel=Vector3(0,0,0)
var linVel=0
var livelliLinVel=[.1,.5,1,1.5]
var livelliDanno=[10,25,50,100]
export var livello=0
var asseRotazione=Vector3(1,0,0)
var angoloRotazione=0.005
var maxDist=1000
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	asseRotazione=Vector3(rng.randf(),rng.randf(),rng.randf()).normalized()
	angoloRotazione=0.001+randf()*angoloRotazione
	director.addAsteroide(self)

func _physics_process(_delta):
#	checkTag()
	transform.basis=transform.basis.rotated(asseRotazione,angoloRotazione)
	if linVel>0:
		var angolo=acos(-vel.dot(global_transform.origin.normalized()))
		if angolo>PI/2:
			vel=vel*.995
		var coll=move_and_collide(vel*linVel)
		if coll!=null:
			if coll.collider.is_in_group("player") or coll.collider.is_in_group("enemy"):
				coll.collider.takeDamage(10)
			elif coll.collider.is_in_group("terra"):
				coll.collider.registraAsteroide(livello)
				director.removeAsteroide(self)
				botto(transform.origin)
		else:
			if global_transform.origin.length()>maxDist:
				pass

func spinta(dir,d):
	vel=-dir.normalized()
	if d==livelliDanno[0]:#razzi blu
		if livello==0:
			linVel=livelliLinVel[1]
		elif livello==1:
			linVel=livelliLinVel[0]
		elif livello==2:
			director.setMessage("It doesn't seem to be enough... harvest smaller asteroids first!",10)
			linVel=0
	elif d==livelliDanno[1]:#razzi verdi
		if livello==0:
			linVel=livelliLinVel[2]
		elif livello==1:
			linVel=livelliLinVel[1]
		elif livello==2:
			linVel=livelliLinVel[0]
	elif d==livelliDanno[2]:#razzi gialli
		linVel=livelliLinVel[2]
	elif d==livelliDanno[3]:#razzi rossi
		linVel=livelliLinVel[3]
	var angolo=acos(-vel.dot(global_transform.origin.normalized()))
	if angolo>PI/2:
		director.setMessage("Be careful: don't push the cheese toward outer space!",10)
	
func botto(pos):
	var b=burst.instance()
	b.transform.origin=pos
	get_tree().current_scene.add_child(b)
	queue_free()

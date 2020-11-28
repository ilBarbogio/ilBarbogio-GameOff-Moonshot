extends KinematicBody

onready var director=get_node("/root/Director")

var livello=4

var dannoPerMuovere=100
var linVel=0
var vel=Vector3(0,0,0)

func _ready():
	director.luna=self

func _physics_process(_delta):
	if linVel!=0:
		var coll=move_and_collide(vel)
#		if coll!=null:
#			if coll.collider.collision_layer==0 or coll.collider.collision_layer==2:
#				coll.collider.takeDamage(100)
#			elif coll.collider.collision_layer==8:
#				director.gameOver(true)
func spinta(dir,d):
	vel=-dir.normalized()
	if d==dannoPerMuovere:#razzo rosso
		var angolo=acos(-vel.dot(global_transform.origin.normalized()))
		print(angolo/PI*180)
		if angolo>PI/4:
			director.setMessage("Next time align the shot with the earth, or we'll never recover the moon! Go get another red rocket!",10)
		else:
			director.gameOver(true)
#			director.setMessage("The moon is moving, keep an eye out for enemies!",10)
#			director.avviaFaseFinale()
#			linVel=.25
#			vel=dir*linVel
	else:
		director.setMessage("You need more power, harvest some more asteroids!",10)

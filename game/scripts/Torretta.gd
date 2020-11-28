extends StaticBody

onready var nav=get_node("/root/VectorNavigation")
onready var boccaUp=get_node("boccaFuocoUp")
onready var boccaDown=get_node("boccaFuocoDown")
onready var Proiettile=preload("res://Scenes/proiettile.tscn")
onready var burst=preload("res://Scenes/MediumBurst.tscn")
onready var sound=get_node("AudioStreamPlayer3D")

var targets=[]
var timers=[0,0]
var baseTimer=.15
var raffica=[8,8]
var baseRicarica=3
var ricarica=[false,false]
var vel=Vector3(0,0,0)

export var damage=1
export var life=60

func _ready():
	pass

func _physics_process(delta):
	timers[0]=timers[0]-delta
	timers[1]=timers[1]-delta
	if targets.size()>0:
		var targetUp=null
		var targetDown=null
		for t in targets:
			var target=instance_from_id(t)
			var dir=(target.transform.origin-transform.origin).normalized()
			var angle=acos(dir.dot(global_transform.basis.y))
			if angle<PI/3:
				targetUp=target
			elif angle>2*PI/3:
				targetDown=target
		if targetUp!=null:
			fuoco(0,boccaUp,targetUp)
		if targetDown!=null:
			fuoco(1,boccaDown,targetDown)

func fuoco(timer,bocca,target):
	bocca.look_at(target.transform.origin,bocca.transform.basis.y)
	if timers[timer]<=0:
		if ricarica[timer]:
			raffica[timer]=raffica[timer]+1
			if raffica[timer]>=10*baseRicarica:
				raffica[timer]=baseRicarica
				ricarica[timer]=false
		else:
			var dir=nav.predictiveToTarget(bocca.global_transform.origin,target.transform.origin,target.vel)
			var p=Proiettile.instance()
			bocca.add_child(p)
			p.setBersaglio(0)
			p.setDamage(damage)
			p.lancio(dir)
			timers[timer]=baseTimer
			raffica[timer]=raffica[timer]-1
			if raffica[timer]<=0:
				ricarica[timer]=true
			sound.play()

func takeDamage(d):
	life=life-d
	if life<=0:
		var b=burst.instance()
		b.transform.origin=global_transform.origin
		get_tree().current_scene.add_child(b)
		queue_free()

func _on_Area_body_entered(body):
	var id=body.get_instance_id()
	var esiste=false
	for t in targets:
		if t==id:
			esiste=true
	if not esiste:
		targets.append(id)
	
func _on_Area_body_exited(body):
	var id=body.get_instance_id()
	var temp=[]
	for t in targets:
		if t!=id:
			temp.append(t)
	targets=temp

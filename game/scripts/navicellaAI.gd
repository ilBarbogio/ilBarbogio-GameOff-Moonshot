extends KinematicBody
#ASTRONAVE AI:
#forward: Z-
onready var nav=get_node("/root/VectorNavigation")

var maxVel=.2
var minVel=.1
var maxAcc=.001
var damp=.75

onready var boccaDaFuoco=get_node("boccaDaFuoco")
onready var Proiettile=preload("res://Scenes/proiettile.tscn")
onready var burst=preload("res://Scenes/MediumBurst.tscn")

export var life=20
export var damage=1
export var detectionRange=50


export var vel=Vector3(0,0,0)
export var acc=Vector3(0,0,0)

var rng=RandomNumberGenerator.new()

#BEHAVIOURS
#[wander,seek,avoid,roll,coast,orbit,evade]
#STRUCTURE
#timers
var behaveTimer=0
export var timers=[1,.1,.25,.25,.5,1.75]
export var maxVels=[.25,.5,.4,.75,.75,.75]
export var maxAccs=[.05,.05,.05,.01,.005,.01]
#status
var oldState=0
var state=0
var newState=0
#0: wander aimlessy
var spreadWander=PI/12
export var spreadWanderNormal=PI/12
export var spreadWanderFlee=PI/2
#stato 1: seek target
var target
var targetData
var pullOutDist=8
var fireAngle=PI/16
var fireBaseTimer=.25
var fireTimer=0
var damage1=3
#stato 2: avoid
var fleeingDist=60
var fleeOnCourse=0
var fleeLimit=50
#stato 3: roll
var rollAngle=PI/8
#stato 4: coast
var maxCoastAngle=PI/2 #angle to end coasting at

func _ready():
	rng.randomize()
	get_node("Detector/CollisionShape").shape.radius=detectionRange

func _physics_process(delta):
	checkStateChange(delta)
	acc=acc.normalized()*maxAcc
	vel=vel.linear_interpolate(vel+acc,damp)
	if vel.length()>maxVel:
		vel=vel.normalized()*maxVel
	var _coll=move_and_collide(vel)
	#adjust model rotation
	if vel.length()>0:
		var variazione=global_transform.origin+vel
		transform=transform.looking_at(variazione,transform.basis.y)
		
	if Input.is_action_pressed("ui_select"):
		checkFire()

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode>=49 and event.scancode<=53:
				queueState(event.scancode-49,0)

func queueState(status,time):
	behaveTimer=time
	newState=status
func checkStateChange(delta):
	behaveTimer=behaveTimer-delta
	fireTimer=fireTimer-delta
	applyState()
	if behaveTimer<=0:
		nextState()
func nextState():
	oldState=state
	state=newState
func applyState():
	if state==0: #wander aimlessy
#		if oldState==2:
#			avoid()
#			queueState(2,0)
		wander()
	elif state==1: #seeking target
		if target!=null:
			computeTargetData()
			checkFire()
			seek()
			if targetData[0]<pullOutDist:#when next to target
				queueState(2,0)#goes to avoiding immediatly
			else:
				queueState(1,timers[1])#or continues seeking
		else:
			wander()
	elif state==2: #avoid target, for fleeing
		if target!=null:
			fleeOnCourse=fleeOnCourse+1 #accumulo tempo di fuga
#			if fleeOnCourse<fleeLimit:#non son fuggito troppo
			computeTargetData()
			if targetData[0]>fleeingDist:#if at safe distance
				queueState(3,0)#attempts roll immediatly
			elif targetData[0]>fleeingDist/2 and rng.randf()>.5:
				queueState(2,timers[2])#or keep fleeing
			avoid()#continuo a fuggire
#			else:#sto scappando da troppo tempo
#				fleeOnCourse=0
#				queueState(0,0)#diversione
		else:
			wander()
	elif state==3: #roll, for spice
		roll()
		if target!=null:
			if newState!=4:
				computeTargetData()
				queueState(4,timers[3])
		else:
			queueState(0,timers[3])
	elif state==4: #coast
		if target!=null:
			computeTargetData()
			coast()
			var angle=acos(global_transform.basis.y.dot(target.vel))
			if angle<maxCoastAngle:#if rotated enough
				queueState(5,0)#switch to orbit immediatly
		else:
			queueState(0,timers[4])
	elif state==5: #orbit
		if target!=null:
			computeTargetData()
			orbit()
			if newState!=1:
				queueState(1,timers[5])#switch to seek with delay
		else:
			queueState(0,0)

func wander():
	maxAcc=maxAccs[state]
	maxVel=maxVels[state]
	if state==0:
		spreadWander=spreadWanderNormal
	else:
		spreadWander=spreadWanderFlee
	if vel.length()!=0:
		acc=nav.randomizeDirection(vel,spreadWander)
func seek():
	checkFire()
	maxAcc=maxAccs[state]
	maxVel=maxVels[state]
	var ratio=targetData[0]/fleeingDist
	if ratio<.4:
		maxVel=maxVel*.75
		maxAcc=maxAcc*1.25
	acc=nav.directionSeekTarget(global_transform.origin,vel,target.transform.origin)
func avoid():
	maxAcc=maxAccs[state]
	maxVel=maxVels[state]
	if targetData[1]>PI/2:
		acc=nav.directionFromTarget(global_transform.origin,target.transform.origin)
	else:
		acc=nav.awayFromDirection(vel,transform.basis.y)
func roll():
	maxAcc=maxAccs[state]
	maxVel=maxVels[state]
	rotate_z(rollAngle)
func coast():
	maxAcc=maxAccs[state]
	maxVel=maxVels[state]
	acc=transform.basis.y
func orbit():
	maxAcc=maxAccs[state]
	maxVel=maxVels[state]
	acc=nav.directionToTarget(transform.origin,target.transform.origin)

func checkFire():
	if fireTimer<=0 and target!=null:
		var dir=target.transform.origin-global_transform.origin
		var angle=acos(-transform.basis.z.dot(dir.normalized()))
		if angle<fireAngle:
			var pro=Proiettile.instance()
			boccaDaFuoco.add_child(pro)
			var dir2=nav.predictiveToTarget(transform.origin,target.transform.origin,target.vel)
			pro.setBersaglio(0)
			pro.setDamage(damage1)
			pro.lancio(dir2)
		fireTimer=fireBaseTimer

func computeTargetData():
	if target!=null:
		var dir=target.transform.origin-global_transform.origin
		var dist=dir.length()
		var angle=acos(-global_transform.basis.z.dot(dir.normalized()))
		targetData=[dist,angle]
	else:
		targetData=[0,0]

func takeDamage(d):
	life=life-d
	if life<=0:
		botto(global_transform.origin)

func botto(pos):
	var b=burst.instance()
	b.transform.origin=pos
	get_tree().current_scene.add_child(b)
	queue_free()

func _on_Detector_body_entered(body):
	target=body
	computeTargetData()
	if targetData[1]>PI/2:#if is looking away from player
		queueState(2,0)
	else:
		queueState(1,0)#instantly goes into seeking





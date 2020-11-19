extends KinematicBody
#FORWARD: Z-
#particelle
var motionParticles
var motorParticles

#parametri moto
var vel=Vector3(0,0,0)
var linVel=0
var minLinVel=0.1
var maxLinVel=1
var linAcc=0
var maxLinAcc=.05
var linDamp=.9
var frenato=false
var linDampFrenato=5

var rollVel=0
var rollAcc=0
var maxRollAcc=.005
var pitchVel=0
var pitchAcc=0
var maxPitchAcc=.005
var rotDamp=.8
var soglieRotDamp=[.9,.8,.65,.5]

#sparacchiamenti
var timerFuoco1=0
var baseTimerFuoco1=.5
var overheatFuoco1=2
var timerFuoco2=0
var baseTimerFuoco2=1

#variabili per effetti
var soglieShake=[0,.05,.1]
var soglieVel=[.1,.35,.85,1.5]

#camera
var camera
var cameraTarget
var cameraTargetPos3rd=Vector3(0,2.5,5)
var cameraTargetPos1st=Vector3(0,2.5,1)
var cameraTargetPosRear=Vector3(0,2.5,-10)
var currentView=1
var cameraSmooth=.5
var minFov=70
var maxFov=110

#shake
onready var noise=OpenSimplexNoise.new()
var noise_y = 0

#fuoco
var boccaDaFuoco
onready var Proiettile=preload("res://Scenes/proiettile.tscn")

onready var global=get_node("/root/Globals")

func _ready():
	#shake
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	#particella
	setupParticles()
	setMotorParticles(1)
	setMotionParticles(1)
	#camera
	camera=get_node("Camera")
	cameraTarget=get_node("CameraTarget")
	camera.set_as_toplevel(true)
	currentView=1
	changeView()
	#fuoco
	boccaDaFuoco=get_node("boccaDaFuoco")
	
func _physics_process(delta):
	#camera follow
	camera.global_transform = camera.global_transform.interpolate_with(cameraTarget.global_transform, cameraSmooth)
	#scala timers
	timerFuochi(delta)
	#movimenti
	controlli()
	if frenato:
		rotDamp=soglieRotDamp[0]
	#pitch
	pitchAcc=pitchAcc*maxPitchAcc
	pitchVel=pitchVel*rotDamp
	pitchVel=pitchVel+pitchAcc
	transform.basis=transform.basis.rotated(transform.basis.x,pitchVel)
	#roll
	rollAcc=rollAcc*maxRollAcc
	rollVel=rollVel*rotDamp
	rollVel=rollVel+rollAcc
	transform.basis=transform.basis.rotated(transform.basis.z,rollVel)
	#linear
	linAcc=linAcc*maxLinAcc
	linVel=linVel*linDamp
	linVel=clamp(linVel,minLinVel,maxLinVel)
	linVel=linVel+linAcc
	if frenato:
		linVel=minLinVel/2
	vel=-transform.basis.z*linVel
	var _coll=move_and_collide(vel)
	#visuali
	velEffetcs()

func controlli():
	if Input.is_action_pressed("game_down"):
		var quanto=Input.get_action_strength("game_down")
		pitchAcc=quanto
	elif Input.is_action_pressed("game_up"):
		var quanto=Input.get_action_strength("game_up")
		pitchAcc=-quanto
	else:
		pitchAcc=0
		
	if Input.is_action_pressed("game_left"):
		var quanto=Input.get_action_strength("game_left")
		rollAcc=quanto
	elif Input.is_action_pressed("game_right"):
		var quanto=Input.get_action_strength("game_right")
		rollAcc=-quanto
	else:
		rollAcc=0
		
	if Input.is_action_pressed("game_thrust"):
		var quanto=Input.get_action_strength("game_thrust")
		linAcc=quanto
		setMotorParticles(2)
	else:
		linAcc=0
		setMotorParticles(1)
	if Input.is_action_pressed("game_break"):
		setMotorParticles(0)
		frenato=true
	else:
		frenato=false
		
	#visuale
	if Input.is_action_just_pressed("game_rear_view"):
		cameraTarget.transform.origin=cameraTargetPosRear
		cameraTarget.transform.basis=cameraTarget.transform.basis.rotated(Vector3(1, 0, 0), PI)
	elif Input.is_action_just_released("game_rear_view"):
		cameraTarget.transform.basis=cameraTarget.transform.basis.rotated(Vector3(1, 0, 0), -PI)
		changeView()
	if Input.is_action_just_released("game_change_view"):
		currentView+=1
		currentView%=2
		changeView();
	#fuoco
	if Input.is_action_pressed("game_fire_1"):
		fuoco1()
	if Input.is_action_pressed("game_fire_2"):
		fuoco2()

#sparamento
func timerFuochi(delta):
	timerFuoco1=timerFuoco1-delta
	overheatFuoco1=overheatFuoco1-delta
	if overheatFuoco1<0:
		overheatFuoco1=0
	global.addOverheat(overheatFuoco1*100)
	timerFuoco2=timerFuoco2-delta
	#HUD
func fuoco1():
	#qui si spara leggero
	if timerFuoco1<=0:
		overheatFuoco1=overheatFuoco1+.01
		var pro=Proiettile.instance()
		boccaDaFuoco.add_child(pro)
		pro.lancio(-boccaDaFuoco.global_transform.basis.z)
		timerFuoco1=baseTimerFuoco1
func fuoco2():
	#qui si spara pesante
	if timerFuoco2<=0:
		var pro=Proiettile.instance()
		boccaDaFuoco.add_child(pro)
		pro.lancio(-boccaDaFuoco.global_transform.basis.z)
		timerFuoco2=baseTimerFuoco2

#visuali
func changeView():
	if(currentView==0):
		cameraSmooth=.9
		cameraTarget.transform.origin=cameraTargetPos1st
	elif(currentView==1):
		cameraSmooth=.5
		cameraTarget.transform.origin=cameraTargetPos3rd

func velEffetcs():
	var velNorm=linVel/(maxLinVel-minLinVel);
	if velNorm<soglieVel[0]:
		setMotionParticles(0)
		rotDamp=soglieRotDamp[0]
	elif velNorm < soglieVel[1]:
		setMotionParticles(1)
		rotDamp=soglieRotDamp[1]
	elif velNorm<soglieVel[2]:
		setMotionParticles(2)
		#shake
		noise_y += 1
		camera.h_offset = soglieShake[1]*noise.get_noise_2d(noise.seed*2, noise_y)
		camera.v_offset = soglieShake[1]*noise.get_noise_2d(noise.seed*3, noise_y)
		#angdamp
		rotDamp=soglieRotDamp[2]
	else:
		setMotionParticles(3)
		#shake		
		noise_y += 1
		camera.h_offset = soglieShake[2]*noise.get_noise_2d(noise.seed*2, noise_y)
		camera.v_offset = soglieShake[2]*noise.get_noise_2d(noise.seed*3, noise_y)
		#angdamp
		rotDamp=soglieRotDamp[3]
	#fov
	camera.fov=minFov+velNorm*(maxFov-minFov)

#gestione particelle
func setupParticles():
	#Dx/SxBase,Dx/Sx,Vel1/2/3
	motorParticles=[
		get_node("particelle/particleDxBase"),
		get_node("particelle/particleSxBase"),
		get_node("particelle/particleDx"),
		get_node("particelle/particleSx")]
	motionParticles=[
		get_node("particelle/strisceVelocità1"),
		get_node("particelle/strisceVelocità2"),
		get_node("particelle/strisceVelocità3")]
func setMotorParticles(l):
	var mask=[false,false,false,false]
	if l==1:
		mask=[true,true,false,false]
	elif l==2:
		mask=[true,true,true,true]
	for i in range(mask.size()):
		motorParticles[i].set_emitting(mask[i])
func setMotionParticles(l):
	var mask=[false,false,false]
	if l==1:
		mask=[true,false,false]
	elif l==2:
		mask=[true,true,false]
	elif l==3:
		mask=[true,true,true]
	for i in range(mask.size()):
		motionParticles[i].set_emitting(mask[i])

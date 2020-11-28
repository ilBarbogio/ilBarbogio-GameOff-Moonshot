extends KinematicBody
#FORWARD: Z-
#particelle
var motionParticles
var motorParticles
var fireParticles

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
var yawVel=0
var yawAcc=0
var maxYawAcc=.002
var rotDamp=.8
var soglieRotDamp=[.9,.8,.65,.5]

var primaryRoll=true

#variabili per effetti
var soglieShake=[0,.05,.1]
var soglieVel=[.1,.35,.85,1.5]

#camera
var camera
var cameraTarget
var cameraTargetPos3rd=Vector3(0,2.5,5)
var cameraTargetPos1st=Vector3(0,1.5,-.2)
var cameraTargetPosRear=Vector3(0,1.5,-5)
var currentView=1
var cameraSmooth=.5
var minFov=70
var maxFov=110

#shake
onready var noise=OpenSimplexNoise.new()
var noise_y = 0

#fuoco
var target
onready var boccaDaFuoco1=get_node("boccaDaFuoco1")
onready var boccaDaFuoco2=get_node("boccaDaFuoco2")
onready var Proiettile=preload("res://Scenes/proiettile.tscn")
onready var Missile=preload("res://Scenes/missile.tscn")
onready var burst=preload("res://Scenes/MediumBurst.tscn")
export var damageFuoco1=1
var timerFuoco1=0
var baseTimerFuoco1=.1
var overheatFuoco1=0
var maxOverheatFuoco=100
var jamFuoco1=false
export var damageFuoco2=[10,25,50,100]
var munizioniFuoco2=10
var maxMunizioniFuoco2=[10,5,2,1]
var tipoFuoco2=0
var prossimoTipoFuoco2=0
var timerFuoco2=0
var baseTimerFuoco2=1
var targetLocked=false
var sogliaPuntamento=.5
var timerPuntamento=0

onready var mirino=get_node("mirino")
var distanzaMirino=50
var misuraMirino=-1
var posMirino=Vector3(0,0,-distanzaMirino)

onready var suonoFuoco1=get_node("suoni/fuoco1")
onready var suonoFuoco2=get_node("suoni/fuoco2")
onready var suonoHit=get_node("suoni/hit")
onready var suonoMotore=get_node("suoni/motore")
var livelliSuonoMotore=[-10,-8,-6,-4]

var refilling=false
#vita
var life=100

#radar
var radarRadius=50
var contacts=[]
var targets=[]

onready var director=get_node("/root/Director")
onready var nav=get_node("/root/VectorNavigation")

#animazioni
onready var aniMissile=get_node("modellonavicella/AnimationMissile")
onready var aniCalotta=get_node("modellonavicella/AnimationCalotta")
onready var aniFire1=get_node("modellonavicella/AnimationFire1")
var calottaChiusa=false
var inAtmosfera=true

func _ready():
	#registro con il director
	director.setPlayerId(get_instance_id())
	radarRadius=director.getRadarRadius()
	life=director.getPlayerLife()
	munizioniFuoco2=director.getPlayerMissiles()
	get_node("AreaRadar/CollisionShape").shape.radius=radarRadius
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
	
func _physics_process(delta):
	#camera follow
	camera.global_transform = camera.global_transform.interpolate_with(cameraTarget.global_transform, cameraSmooth)
	#scala timers
	timerFuochi(delta)
	posizionaMirino()
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
	#yaw
	yawAcc=yawAcc*maxYawAcc
	yawVel=yawVel*rotDamp
	yawVel=yawVel+yawAcc
	transform.basis=transform.basis.rotated(transform.basis.y,yawVel)
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
	#calotta
	if global_transform.origin.length()>director.hAtmosferaEstesaTerra:
		inAtmosfera=false
	else:
		inAtmosfera=true
	if not inAtmosfera and not calottaChiusa:
		animaCalotta(true)
	if inAtmosfera and calottaChiusa:
		animaCalotta(false)
	
		
	
	if refilling:
		refill()

func controlli():
	#pitch
	if Input.is_action_pressed("game_down"):
		var quanto=Input.get_action_strength("game_down")
		pitchAcc=quanto
	elif Input.is_action_pressed("game_up"):
		var quanto=Input.get_action_strength("game_up")
		pitchAcc=-quanto
	else:
		pitchAcc=0
	#roll (if primaryRoll)
	if Input.is_action_pressed("game_left"):
		var quanto=Input.get_action_strength("game_left")
		rollAcc=quanto
	elif Input.is_action_pressed("game_right"):
		var quanto=Input.get_action_strength("game_right")
		rollAcc=-quanto
	else:
		rollAcc=0
	#yaw (if !primaryRoll)
	if Input.is_action_pressed("game_left_2"):
		var quanto=Input.get_action_strength("game_left_2")
		yawAcc=quanto
	elif Input.is_action_pressed("game_right_2"):
		var quanto=Input.get_action_strength("game_right_2")
		yawAcc=-quanto
	else:
		yawAcc=0
	#thrust
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

func refill():
	if prossimoTipoFuoco2!=tipoFuoco2:
		tipoFuoco2=prossimoTipoFuoco2
		changeMissile()
	if life<100:
		life=life+.5
		director.setPlayerLife(life)
	if munizioniFuoco2>maxMunizioniFuoco2[tipoFuoco2]:
		munizioniFuoco2=maxMunizioniFuoco2[tipoFuoco2]
		director.setPlayerMissiles(munizioniFuoco2)
	if munizioniFuoco2<=0:
		munizioniFuoco2=munizioniFuoco2+1
		director.setPlayerMissiles(munizioniFuoco2)
#sparamento
func timerFuochi(delta):
	#arma leggera
	timerFuoco1=timerFuoco1-delta
	overheatFuoco1=overheatFuoco1-1
	if jamFuoco1 and overheatFuoco1<=0:
		jamFuoco1=false
	if overheatFuoco1>=100:
		jamFuoco1=true
	overheatFuoco1=clamp(overheatFuoco1,0,maxOverheatFuoco)
	director.setOverheat1(overheatFuoco1)
	#arma pesante
	if targetLocked:
		timerFuoco2=timerFuoco2+delta
	if not aniMissile.is_playing():
		get_node("modellonavicella/ledVerde001/lucecruscotto").visible=true
		get_node("modellonavicella/ledVerde002/luceretro").visible=true
	elif aniMissile.current_animation_position>.5:
		changeMissile()
		
func fuoco1():
	#qui si spara leggero
	if timerFuoco1<=0 and not jamFuoco1:
		fireFireParticles(0)
		aniFire1.play("firing1")
		suonoFuoco1.play()
		overheatFuoco1=overheatFuoco1+15
		var pro=Proiettile.instance()
		boccaDaFuoco1.add_child(pro)
		var dir=-boccaDaFuoco1.global_transform.basis.z
		if target!=null:
			if target.collision_layer!=16:
				dir=nav.predictiveToTarget(transform.origin,target.transform.origin,target.vel)
			else:
				dir=-boccaDaFuoco1.global_transform.basis.z
		pro.setBersaglio(1)
		pro.setDamage(damageFuoco1)
		pro.lancio(dir)
		timerFuoco1=baseTimerFuoco1
func fuoco2():
	#qui si spara pesante, basato sull'animazione della rastrelliera
	if not aniMissile.is_playing() and munizioniFuoco2>0 and target!=null and timerPuntamento>=sogliaPuntamento:
		suonoFuoco2.play()
		munizioniFuoco2=munizioniFuoco2-1
		director.setPlayerMissiles(munizioniFuoco2)
		animaMissile()
		changeMissile(false)
		var miss=Missile.instance()
		boccaDaFuoco2.add_child(miss)
		miss.setDamage(damageFuoco2[tipoFuoco2])
		miss.lancio(-boccaDaFuoco2.global_transform.basis.z,target)
		targetLocked=false
		timerFuoco2=0

func animaMissile():
	aniMissile.play("missileExit")
	get_node("modellonavicella/ledVerde001/lucecruscotto").visible=false
	get_node("modellonavicella/ledVerde002/luceretro").visible=false

func changeMissile(vis=true):
	get_node("modellonavicella/rocketracket/ancorazzi/razzoblu").visible=false
	get_node("modellonavicella/rocketracket/ancorazzi/razzoverde").visible=false
	get_node("modellonavicella/rocketracket/ancorazzi/razzogiallo").visible=false
	get_node("modellonavicella/rocketracket/ancorazzi/razzorosso").visible=false
	if vis:
		if tipoFuoco2==0:
			get_node("modellonavicella/rocketracket/ancorazzi/razzoblu").visible=true
		elif tipoFuoco2==1:
			get_node("modellonavicella/rocketracket/ancorazzi/razzoverde").visible=true
		elif tipoFuoco2==2:
			get_node("modellonavicella/rocketracket/ancorazzi/razzogiallo").visible=true
		elif tipoFuoco2==3:
			director.setMessage("You reached maximum firepower: GO FOR THE MOON!",10)
			get_node("modellonavicella/rocketracket/ancorazzi/razzorosso").visible=true
	
func posizionaMirino():
	if target!=null:
		timerPuntamento=timerPuntamento+.01
		targetLocked=true
		var pos=camera.unproject_position(target.global_transform.origin)
		mirino.global_transform.origin=camera.project_position(pos,distanzaMirino)
		mirino.get_node("centro").mesh.material.albedo_color=Color(1,0,0,1)
		if timerPuntamento>=sogliaPuntamento:
			mirino.get_node("extraO").visible=true
			mirino.get_node("extraV").visible=true
		
	else:
		timerPuntamento=0
		mirino.get_node("extraO").visible=false
		mirino.get_node("extraV").visible=false
		targetLocked=false
		mirino.transform.origin=posMirino
		mirino.get_node("centro").mesh.material.albedo_color=Color(1,1,0,1)

func takeDamage(d):
	suonoHit.play()
	life=life-d
	director.setPlayerLife(life)
	if life<0:
		director.gameOver(false)

func botto(pos):
	var b=burst.instance()
	b.transform.origin=pos
	get_tree().current_scene.add_child(b)
	queue_free()

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
		suonoMotore.unit_db=livelliSuonoMotore[0]
		rotDamp=soglieRotDamp[0]
	elif velNorm < soglieVel[1]:
		setMotionParticles(1)
		suonoMotore.unit_db=livelliSuonoMotore[1]
		rotDamp=soglieRotDamp[1]
	elif velNorm<soglieVel[2]:
		setMotionParticles(2)
		suonoMotore.unit_db=livelliSuonoMotore[2]
		#shake
		noise_y += 1
		if currentView ==1:
			camera.h_offset = soglieShake[1]*noise.get_noise_2d(noise.seed*2, noise_y)
			camera.v_offset = soglieShake[1]*noise.get_noise_2d(noise.seed*3, noise_y)
		#angdamp
		rotDamp=soglieRotDamp[2]
	else:
		setMotionParticles(3)
		suonoMotore.unit_db=livelliSuonoMotore[3]
		#shake		
		if currentView ==1:
			noise_y += 1
			camera.h_offset = soglieShake[2]*noise.get_noise_2d(noise.seed*2, noise_y)
			camera.v_offset = soglieShake[2]*noise.get_noise_2d(noise.seed*3, noise_y)
		#angdamp
		rotDamp=soglieRotDamp[3]
	#fov
	camera.fov=minFov+velNorm*(maxFov-minFov)

func animaCalotta(chiudi):
	calottaChiusa=chiudi
	if chiudi:
		aniCalotta.play("calotta")
	else:
		aniCalotta.play_backwards("calotta")

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
	fireParticles=[
		get_node("particelle/particleFire1")
	]
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
func fireFireParticles(i):
	fireParticles[i].restart()

func _on_Area_body_entered(body):
	targets.append(body)
	if target==null:
		targets=[body]
	target=body

func _on_Area_body_exited(body):
	var temp=[]
	var id=body.get_instance_id()
	for t in targets:
		if t.get_instance_id()!=id:
			temp.append(t)
	targets=temp
	if targets.size()==0:
		target=null

func _on_AreaRadar_body_entered(body):
	var id=body.get_instance_id()
	var esiste=false
	for t in contacts:
		if t==id:
			esiste=true
	if not esiste:
		contacts.append(id)
	director.setContacts(contacts)

func _on_AreaRadar_body_exited(body):
	var id=body.get_instance_id()
	var temp=[]
	for t in contacts:
		if t!=id:
			temp.append(t)
	contacts=temp
	director.setContacts(contacts)

func setRefill(b):
	refilling=b

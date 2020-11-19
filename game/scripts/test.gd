extends RigidBody

var rng = RandomNumberGenerator.new()

var partDx
var partSx
var partVel1
var partVel2
var partVel3

var maxVel=12
var minVel=2
var soglieShake=[0,.01,.05]
var soglieVel=[.1,.35,.85,1.5]
var soglieAngDamp=[4,8,12]

var camera
var cameraTarget
var cameraTargetPos3rd=Vector3(0,-5,2.5)
var cameraTargetPos1st=Vector3(0,-1,2.5)
var cameraTargetPosRear=Vector3(0,8,1)
var currentView=1
var cameraSmooth=.5
var minFov=70
var maxFov=110


# Called when the node enters the scene tree for the first time.
func _ready():
	#varie
	rng.randomize()
	angular_damp=soglieAngDamp[0]
	#particelle
	partDx=get_node("particelle/particleDx")
	partSx=get_node("particelle/particleSx")
	partVel1=get_node("particelle/strisceVelocità1")
	partVel2=get_node("particelle/strisceVelocità2")
	partVel3=get_node("particelle/strisceVelocità3")
	#camera
	camera=get_node("Camera")
	cameraTarget=get_node("CameraTarget")
	camera.set_as_toplevel(true)
	
func _physics_process(delta):
	#camera.look_at(cameraTarget.global_transform.origin,Vector3(0,1,0))
	camera.global_transform = camera.global_transform.interpolate_with(cameraTarget.global_transform, cameraSmooth)
		
	controlli()
	velEffetcs()

func controlli():
	if Input.is_action_pressed("ui_up"):
		self.add_torque(-1*global_transform.basis.x);
	if Input.is_action_pressed("ui_down"):
		self.add_torque(global_transform.basis.x);
	if Input.is_action_pressed("ui_right"):
		self.add_torque(global_transform.basis.y);
	if Input.is_action_pressed("ui_left"):
		self.add_torque(-1*global_transform.basis.y);
	if Input.is_action_pressed("ui_select"):
		self.add_central_force(global_transform.basis.y);
		partEffects(true)
	else:
		self.add_central_force(global_transform.basis.y*.1);
		partEffects(false)
	#visuale
	if Input.is_action_just_pressed("ui_accept"):
		cameraTarget.transform.origin=cameraTargetPosRear
		cameraTarget.transform.basis=cameraTarget.transform.basis.rotated(Vector3(1, 0, 0), PI)
	elif Input.is_action_just_released("ui_accept"):
		cameraTarget.transform.basis=cameraTarget.transform.basis.rotated(Vector3(1, 0, 0), -PI)
		changeView()
	if Input.is_action_just_released("ui_focus_next"):
		currentView+=1
		currentView%=2
		changeView();
	#fuoco
	if Input.is_action_just_pressed("fire"):
		fuoco()
func changeView():
	if(currentView==0):
		cameraSmooth=.9
		cameraTarget.transform.origin=cameraTargetPos1st
	elif(currentView==1):
		cameraSmooth=.5
		cameraTarget.transform.origin=cameraTargetPos3rd

func partEffects(onoff):
	if(onoff):
		partDx.set_emitting(true);
		partSx.set_emitting(true);
	else:
		partDx.set_emitting(false);
		partSx.set_emitting(false);

func velEffetcs():
	var velNorm=linear_velocity.length()/(maxVel-minVel);
	#particles
	#if velNorm<soglieVel[0]:
		#velNorm=soglieVel[0]
	if velNorm < soglieVel[1]:
		partVel2.set_emitting(false);
		partVel3.set_emitting(false);
		angular_damp=soglieAngDamp[0]
	elif velNorm<soglieVel[2]:
		partVel2.set_emitting(true);
		partVel3.set_emitting(false);
		camera.h_offset=rng.randf_range(-soglieShake[1],soglieShake[1])
		camera.v_offset=rng.randf_range(-soglieShake[1],soglieShake[1])
		angular_damp=soglieAngDamp[1]
	else:
		partVel3.set_emitting(true);
		camera.h_offset=rng.randf_range(-soglieShake[2],soglieShake[2])
		camera.v_offset=rng.randf_range(-soglieShake[2],soglieShake[2])
		angular_damp=soglieAngDamp[2]
	#fov
	camera.fov=minFov+velNorm*(maxFov-minFov)

func fuoco():
	print("fuoco")
	#qui si spara

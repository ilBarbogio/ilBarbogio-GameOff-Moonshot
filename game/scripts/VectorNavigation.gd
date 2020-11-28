extends Node

var rng=RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func randomizeDirection(dir,spread):
	var perp=pVector(dir)
	return dir.normalized()+perp*tan(spread)
	
func directionToTarget(pos,target):
	var dir=target-pos
	return dir.normalized()
func directionFromTarget(pos,target):
	return -directionToTarget(pos,target)
	
func predictiveToTarget(pos,target,vel):
	return directionToTarget(pos,target+vel)
func predictiveFromTarget(pos,target,vel):
	return -predictiveToTarget(pos,target,vel)

func directionSeekTarget(pos,vel,target):
	var dir=target-pos
	var acc=dir-vel
	return acc.normalized()
func predictiveSeekTarget(pos,velP,target,velT):
	var dir=target+velT-pos
	return (dir-velP).normalized()
	
func flankTarget(velP,velT):
	return (velT-velP).normalized()
		
func steerToCoast(up,vel,angle):
	var l=vel.length()*tan(angle)
	return up.cross(vel).normalized()*l
	
func awayFromDirection(velP,up):
	var d=velP.cross(up)
	return d.normalized()


func pVector(v):
	var u=Vector3(rng.randf()-.5,rng.randf()-.5,rng.randf()-.5)
	var c=u.cross(v)
	if c.length()==0:
		if c.cross(Vector3(1,0,0)).length()==0:
			c.y=c.y+1
		else:
			c.x=c.x+1
	return c.normalized()

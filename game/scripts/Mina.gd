extends Spatial

onready var part=preload("res://Scenes/MediumBurst.tscn")
var targets=[]
export var detectionDist=10
export var detonationDist=2
export var linVel=.25
export var damage=35

func _ready():
	get_node("AreaMina/CollisionShape").shape.set_radius(detectionDist)

func _physics_process(_delta):
	if targets.size()>0:
		var t=instance_from_id(targets[0])
		var dir=t.transform.origin-transform.origin
		if dir.length()<=detonationDist:
			var ratio=dir.length()/detonationDist
			var d=damage*((ratio)/2+.5)
			t.takeDamage(d)
			var p=part.instance()
			p.transform.origin=transform.origin
			get_tree().current_scene.add_child(p)
			queue_free()
		else:
			transform=transform.translated(dir.normalized()*linVel)


func _on_AreaMina_body_entered(body):
	var id=body.get_instance_id()
	var esiste=false
	for t in targets:
		if t==id:
			esiste=true
	if not esiste:
		targets.append(id)

func _on_AreaMina_body_exited(body):
	var id=body.get_instance_id()
	var temp=[]
	for t in targets:
		if t!=id:
			temp.append(t)
	targets=temp

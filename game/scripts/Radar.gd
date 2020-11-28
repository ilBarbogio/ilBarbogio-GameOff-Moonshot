extends Spatial

onready var director=get_node("/root/Director")
onready var screen=Vector2(get_viewport().size.x,get_viewport().size.y)
onready var screenCenter=screen*.5
var position=Vector2(100,100)
onready var camera=get_node("RadarCamera")
var contacts=[]
var center
var radarRadius=30
var displayRadius=1
var origin=Vector3(2000,0,0)

func _ready():
	radarRadius=director.getRadarRadius()

func _process(_delta):
	if center==null:
		center=instance_from_id(director.getPlayerId())

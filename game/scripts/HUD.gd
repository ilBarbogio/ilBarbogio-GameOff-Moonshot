extends CanvasLayer

onready var director=get_node("/root/Director")
onready var overheatBar=get_node("MarginContainer/CenterContainer/HBoxContainer2/MarginContainer/HBoxContainer/overheatBar")
onready var lifeBar=get_node("MarginContainer/CenterContainer/HBoxContainer2/MarginContainer2/HBoxContainer2/lifeBar")
onready var nMissili=get_node("MarginContainer/CenterContainer/HBoxContainer2/MarginContainer3/HBoxContainer/nMissili")
onready var mis1 = preload("res://imgs/iconaMissileBlu.png")
onready var mis2 = preload("res://imgs/iconaMissileVerde.png")
onready var mis3 = preload("res://imgs/iconaMissileGiallo.png")
onready var mis4 = preload("res://imgs/iconaMissileRosso.png")
onready var iconeMissili=[mis1,mis2,mis3,mis4]

var tags=[]
var tagTerra
var tagLuna
onready var tagB = preload("res://imgs/tagAsteroideBlu.png")
onready var tagV = preload("res://imgs/tagAsteroideVerde.png")
onready var tagG = preload("res://imgs/tagAsteroideGiallo.png")
onready var tagR = preload("res://imgs/tagLuna.png")
onready var textures=[tagB,tagV,tagG]

func _ready():
	pass

func _process(_delta):
	if overheatBar!=null:
		overheatBar.value=director.playerOverheat
	if lifeBar!=null:
		lifeBar.value=director.playerLife
	if nMissili!=null:
		nMissili.text=str(director.playerMissiles)
		get_node("MarginContainer/CenterContainer/HBoxContainer2/MarginContainer3/HBoxContainer/Sprite").set_texture(iconeMissili[director.getPlayerMissilesTier()])
	if director.HUD==null:
		director.HUD=self
		director.setMessage("Follow radar cues to find asteroids \n collect them and build up power, aiming for the moon!\n Hit them with missiles, but watch out:\n if you send them into outer space, you lose them (and the game)!",10)
		setupTags()
	if tags.size()>0:
		disegnaTags()

func setupTags():
	for a in director.asteroidi:
		var s=Sprite.new()
		s.texture=textures[a.livello]
		s.visible=false
		tags.append([a.get_instance_id(),s])
		add_child(s)
	#terra
	tagTerra=Sprite.new()
	tagTerra.texture=tagR
	tagTerra.visible=false
	add_child(tagTerra)
	#luna
	tagLuna=Sprite.new()
	tagLuna.texture=tagR
	tagLuna.visible=false
	add_child(tagLuna)

func disegnaTags():
	for t in tags:
		t[1].visible=false
	var player=instance_from_id(director.getPlayerId())
	if player!=null and director.asteroidi.size()>0:
		for a in director.asteroidi:
			for t in tags:
				if director.radarOn:
					t[1].visible=true
					if t[0]==a.get_instance_id():
						var pos2D=player.camera.unproject_position(a.global_transform.origin)
						if onScreen(pos2D):
							if not player.camera.is_position_behind(a.global_transform.origin):
								t[1].scale.x=1
								t[1].scale.y=1
								t[1].position=pos2D
							else:
								t[1].scale.x=.5
								t[1].scale.y=.5
								t[1].position=edgeScreen(pos2D)
						else:
							t[1].scale.x=.5
							t[1].scale.y=.5
							t[1].position=edgeScreen(pos2D)
				else:
					t[1].visible=false
	#luna
	if director.radarOn:
		tagLuna.visible=true
		var pos2D=player.camera.unproject_position(director.luna.global_transform.origin)
		if onScreen(pos2D):
			if not player.camera.is_position_behind(director.luna.global_transform.origin):
				tagLuna.scale.x=2
				tagLuna.scale.y=2
				tagLuna.position=pos2D
			else:
				tagLuna.scale.x=1
				tagLuna.scale.y=1
				tagLuna.position=edgeScreen(pos2D)
		else:
			tagLuna.scale.x=1
			tagLuna.scale.y=1
			tagLuna.position=edgeScreen(pos2D)
	else:
		tagLuna.visible=false
	#luna
	if director.radarOn:
		tagTerra.visible=true
		var pos2D=player.camera.unproject_position(director.terra.global_transform.origin)
		if onScreen(pos2D):
			if not player.camera.is_position_behind(director.terra.global_transform.origin):
				tagTerra.scale.x=2
				tagTerra.scale.y=2
				tagTerra.position=pos2D
			else:
				tagTerra.scale.x=1
				tagTerra.scale.y=1
				tagTerra.position=edgeScreen(pos2D)
		else:
			tagTerra.scale.x=1
			tagTerra.scale.y=1
			tagTerra.position=edgeScreen(pos2D)
	else:
			tagTerra.visible=false
func onScreen(d):
	if d.x>=0 and d.x<=get_viewport().size.x:
		if d.y>=0 and d.y<=get_viewport().size.y:
			return true
		else:
			return false
	else:
		return false

func edgeScreen(p):
	var centro=Vector2(get_viewport().size.x/2,get_viewport().size.y/2)
	var dir=p-centro
	var l=min(get_viewport().size.x/2,get_viewport().size.y/2)
	return centro+dir.normalized()*l*.9

extends CanvasLayer

onready var global=get_node("/root/Globals")
onready var overheatBar=get_node("MarginContainer/CenterContainer/overheatBar")

func _ready():
	pass
func _process(_delta):
	var val=global.playerOverheat
	print(val)
	overheatBar.value=val

extends Control

onready var director=get_node("/root/Director")
onready var testo=get_node("PanelContainer/CenterContainer/VBoxContainer/Label")

func _ready():
	if director.risultato:
		testo.text="YOU WIN\underwelming, isn't it?"
	else:
		testo.text="YOU LOSE\underwelming, isn't it?"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MenuButton_pressed():
	get_tree().change_scene("res://menu.tscn")

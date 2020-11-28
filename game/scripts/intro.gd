extends Control

onready var sprite=get_node("PanelContainer/CenterContainer/Sprite")
var intro1 = preload("res://imgs/intro1.png")
var intro2 = preload("res://imgs/intro2.png")
var intro3 = preload("res://imgs/intro3.png")
var intro4 = preload("res://imgs/intro4.png")
var intro5 = preload("res://imgs/intro5.png")
onready var imgs=[intro1,intro2,intro3,intro4,intro5]
var cursore=0

func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_released("ui_select"):
		cursore=cursore+1
		if cursore<imgs.size():
			sprite.set_texture(imgs[cursore])
		else:
			get_tree().change_scene("res://menu.tscn")
	if event.is_action_released("ui_accept"):
		get_tree().change_scene("res://menu.tscn")

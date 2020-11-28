extends Control

func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	get_tree().change_scene("res://gioco.tscn")

func _on_AboutButton_pressed():
	get_tree().change_scene("res://about.tscn")

func _on_HowToButton2_pressed():
	get_tree().change_scene("res://howto.tscn")
	
func _on_QuitButton_pressed():
	get_tree().quit()


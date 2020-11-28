extends Spatial
onready var part2=get_node("fumo")
onready var suonoBoom=get_node("suonoBoom")
func _ready():
	part2.restart()
	suonoBoom.play()
func _process(_delta):
	if not part2.is_emitting():
		queue_free()

extends Spatial
onready var part1=get_node("schegge")
onready var part2=get_node("fumo")
onready var suonoBoom=get_node("suonoBoom")
func _ready():
	part1.restart()
	part2.restart()
	suonoBoom.play()
func _process(_delta):
	if not part1.is_emitting() and not part2.is_emitting():
		queue_free()

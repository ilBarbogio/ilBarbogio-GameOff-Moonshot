extends Spatial

onready var part=get_node("CPUParticles")
onready var suonoHit=get_node("suoniHit")

func _ready():
	part.restart()
	suonoHit.play()
func _process(_delta):
	if not part.is_emitting():
		queue_free()

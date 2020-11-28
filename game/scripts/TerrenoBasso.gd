extends Spatial

onready var director=get_node("/root/Director")

var collisionDamage=10
var livelloParmisan=0
var livelloEmmental=0
var livelloGouda=2
var puntiParmisan=2
var puntiEmmental=3
var puntiGouda=5
var punteggio=0
var livelloTerra=0

func _ready():
	director.terra=self

#func _process(delta):
#	pass

func registraAsteroide(lvl):
	if lvl==0:
		livelloParmisan=livelloParmisan+1
		punteggio=punteggio+puntiParmisan
		if livelloParmisan==1:
			get_node("asteroidi/parmisansteroide1").visible=true
		if livelloParmisan==2:
			get_node("asteroidi/parmisansteroide2").visible=true
		if livelloParmisan==3:
			get_node("asteroidi/parmisansteroide3").visible=true
	if lvl==1:
		livelloEmmental=livelloEmmental+1
		punteggio=punteggio+puntiEmmental
		if livelloEmmental==1:
			get_node("asteroidi/emmensteroide1").visible=true
		if livelloEmmental==2:
			get_node("asteroidi/emmensteroide2").visible=true
		if livelloEmmental==3:
			get_node("asteroidi/emmensteroide3").visible=true
	if lvl==2:
		livelloGouda=livelloGouda+1
		punteggio=punteggio+puntiGouda
		if livelloGouda==1:
			get_node("asteroidi/goudasteroide1").visible=true
		if livelloGouda==2:
			get_node("asteroidi/goudasteroide2").visible=true
	director.setPunteggioTerra(punteggio)
	
func _on_RefillArea_body_entered(body):
	body.setRefill(true)

func _on_RefillArea_body_exited(body):
	body.setRefill(false)

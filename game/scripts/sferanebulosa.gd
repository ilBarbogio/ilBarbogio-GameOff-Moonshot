extends Spatial

onready var director=get_node("/root/Director"
)
#dimensioni
export var rotVel=.25
var distanzaAtmosfera
var dimensioneTerra
var distanzaAvvicinamento
#parametri
var zona=0 #0:terra, 1:avvicinamento terra, 2:spazio
onready var navicella=get_node("../../Navicella")
onready var animatore=get_node("AnimatoreNebuloso")
#sfera nebulosa
onready var sfera=get_child(0)
#nuvole basse
onready var nuvole=get_child(1)
var rng=RandomNumberGenerator.new()
onready var Gruppo=preload("res://Scenes/GruppoNuvolePiatte.tscn")
export var rangeNumeroNb=[10,30]
export var minHNb=200
var numeroNb
var actHNb

func _ready():
	distanzaAtmosfera=director.hAtmosferaEstesaTerra
	dimensioneTerra=director.hAtmosferaContrattaTerra
	distanzaAvvicinamento=director.distanzaAvvicinamentoTerra
	#sfera nebulosa
	sfera.global_scale(Vector3(distanzaAtmosfera,distanzaAtmosfera,distanzaAtmosfera))
	animatore.play("RotazioneStratoNebuloso")
	#nuvole basse
	actHNb=minHNb
	rng.randomize()
	numeroNb=rng.randi_range(rangeNumeroNb[0],rangeNumeroNb[1])
	for _n in range(numeroNb):
		var g=Gruppo.instance()
		shufflaNb(g,1)
		nuvole.add_child(g)
		actHNb=actHNb+rng.randf_range(minHNb/numeroNb,distanzaAtmosfera/numeroNb)
		if actHNb>distanzaAtmosfera:
			actHNb=distanzaAtmosfera
		var theta=rng.randf_range(0,PI)
		var phi=rng.randf_range(0,2*PI)
		g.transform.origin.y=actHNb
		g.transform=g.transform.rotated(Vector3(1,0,0),theta)
		g.transform=g.transform.rotated(Vector3(0,1,0),phi)
func _process(_delta):
	var quota=navicella.global_transform.origin.length()
	if quota<distanzaAtmosfera:
		if not zona==0:
			zona=0
			sfera.global_scale(Vector3(distanzaAtmosfera,distanzaAtmosfera,distanzaAtmosfera))
			nuvole.global_scale(Vector3(1,1,1))
	elif quota<distanzaAvvicinamento:
		if not zona==1:
			zona=1
		var ratio=(quota-distanzaAtmosfera)/(distanzaAvvicinamento-distanzaAtmosfera)
		var interpolato=distanzaAtmosfera*(1-ratio)+dimensioneTerra*ratio
		sfera.transform.basis.x=sfera.transform.basis.x.normalized()*interpolato
		sfera.transform.basis.y=sfera.transform.basis.y.normalized()*interpolato
		sfera.transform.basis.z=sfera.transform.basis.z.normalized()*interpolato
		nuvole.transform.basis.x=nuvole.transform.basis.x.normalized()*(1-ratio)
		nuvole.transform.basis.y=nuvole.transform.basis.y.normalized()*(1-ratio)
		nuvole.transform.basis.z=nuvole.transform.basis.z.normalized()*(1-ratio)
		
	elif quota>distanzaAvvicinamento:
		if not zona==2:
			zona=2

func shufflaNb(gruppo,d):
	for q in gruppo.get_children():
		q.transform=q.transform.translated(Vector3(rng.randi_range(-d,d),+rng.randi_range(-d,d),0))

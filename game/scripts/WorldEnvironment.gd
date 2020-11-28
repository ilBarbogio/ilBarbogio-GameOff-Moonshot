extends Node

onready var director=get_node("/root/Director")

var coloreSoleTerra=Color(1,1,0,1)
var curvaSoleTerra=.05
var energiaSoleTerra=2
var coloreCieloTerra=Color(0,0,1,1)
var coloreOrizzonteTerra=Color(.3,1,1,1)
var coloreFondoTerra=Color(.1,0,.5,1)
var coloreSoleSpazio=Color(1,1,1,1)
var curvaSoleSpazio=.01
var energiaSoleSpazio=1
var coloreCieloSpazio=Color(0.01,0.01,0.01,1)
var coloreOrizzonteSpazio=Color(.05,.05,.05,1)
var coloreFondoSpazio=Color(0,0,0,1)

onready var cielo=get_node("WorldEnvironment").environment.background_sky

var rTerra
var dAtmEstTerra
var dAtmConTerra
var dAvvTerra
var navicella
# Called when the node enters the scene tree for the first time.
func _ready():
	#recupero dal director
	rTerra=director.raggioTerra
	dAtmEstTerra=director.hAtmosferaEstesaTerra
	dAtmConTerra=director.hAtmosferaContrattaTerra
	dAvvTerra=director.distanzaAvvicinamentoTerra
	#setto valori iniziali colore
	setCieloTerra()

func _process(_delta):
	if navicella==null:
		navicella=instance_from_id(director.getPlayerId())
	else:
		var quota=navicella.global_transform.origin.length()
		var ratio=(quota-rTerra)/(dAtmEstTerra-rTerra)
		if ratio<1:
			#colori cielo
			cielo.sun_color=coloreSoleTerra.linear_interpolate(coloreSoleSpazio,ratio)
			cielo.sun_curve=curvaSoleTerra*(1-ratio)+curvaSoleSpazio*ratio
			cielo.sun_energy=energiaSoleTerra*(1-ratio)+energiaSoleSpazio*ratio
			cielo.sky_top_color=coloreCieloTerra.linear_interpolate(coloreCieloSpazio,ratio)
			cielo.sky_horizon_color=coloreOrizzonteTerra.linear_interpolate(coloreOrizzonteSpazio,ratio)
			cielo.ground_horizon_color=coloreOrizzonteTerra.linear_interpolate(coloreOrizzonteSpazio,ratio)
			cielo.ground_bottom_color=coloreFondoTerra.linear_interpolate(coloreFondoSpazio,ratio)
			
func setCieloTerra():
	cielo.sun_color=coloreSoleTerra
	cielo.sun_curve=curvaSoleTerra
	cielo.sun_energy=energiaSoleTerra
	cielo.sky_top_color=coloreCieloTerra
	cielo.sky_horizon_color=coloreOrizzonteTerra
	cielo.ground_horizon_color=coloreOrizzonteTerra
	cielo.ground_bottom_color=coloreFondoTerra

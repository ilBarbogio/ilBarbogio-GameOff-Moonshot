extends WorldEnvironment

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

export var distanzaAtmosfera=500
onready var navicella=get_node("../../Navicella")
# Called when the node enters the scene tree for the first time.
func _ready():
	environment.background_sky.sun_color=coloreSoleTerra
	environment.background_sky.sun_curve=curvaSoleTerra
	environment.background_sky.sun_energy=energiaSoleTerra
	environment.background_sky.sky_top_color=coloreCieloTerra
	environment.background_sky.sky_horizon_color=coloreOrizzonteTerra
	environment.background_sky.ground_horizon_color=coloreOrizzonteTerra
	environment.background_sky.ground_bottom_color=coloreFondoTerra

func _process(_delta):
	var quota=navicella.global_transform.origin.length()
	var ratio=quota/distanzaAtmosfera
	if ratio<=1:
		environment.background_sky.sun_color=coloreSoleTerra.linear_interpolate(coloreSoleSpazio,ratio)
		environment.background_sky.sun_curve=curvaSoleTerra*(1-ratio)+curvaSoleSpazio*ratio
		environment.background_sky.sun_energy=energiaSoleTerra*(1-ratio)+energiaSoleSpazio*ratio
		environment.background_sky.sky_top_color=coloreCieloTerra.linear_interpolate(coloreCieloSpazio,ratio)
		environment.background_sky.sky_horizon_color=coloreOrizzonteTerra.linear_interpolate(coloreOrizzonteSpazio,ratio)
		environment.background_sky.ground_horizon_color=coloreOrizzonteTerra.linear_interpolate(coloreOrizzonteSpazio,ratio)
		environment.background_sky.ground_bottom_color=coloreFondoTerra.linear_interpolate(coloreFondoSpazio,ratio)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

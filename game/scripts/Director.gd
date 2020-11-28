extends Node

var risultato

#giocatore
var playerOverheat=0
var playerId
var playerContacts=[]
var playerLife=100
var playerMissiles=10
var radarRadius=50

#ambiente
var terra
var raggioTerra=80
var hAtmosferaEstesaTerra=200#dimensione atmosfera espansa
var hAtmosferaContrattaTerra=100#atmosfera contratta
var distanzaAvvicinamentoTerra=350#distanza per contrarre l'atmosfera
var punteggioTerra=0

var luna

var asteroidi=[]
var radarOn=false

#rapporti con HUD
var HUD
var message=""
var messageTimer=0
var messageLifetime=5

func _ready():
	pass

func _input(event):
	if event.is_action_released("game_radar"):
		radarOn=not radarOn

func setOverheat1(val):
	playerOverheat=val

#giocatore e radar
func setPlayerId(id):
	playerId=id
func getPlayerId():
	return playerId
func setRadarRadius(r):
	radarRadius=r
func getRadarRadius():
	return radarRadius
func getContacts():
	return playerContacts	
func setContacts(list):
	playerContacts=list
func setPlayerLife(l):
	if l!=0:
		playerLife=l
	else:
		#gameOver
		print("GAMEOVER")
func getPlayerLife():
	return playerLife
func setPlayerMissiles(n):
	playerMissiles=n
func getPlayerMissiles():
	return playerMissiles
func getPlayerMissilesTier():
	return instance_from_id(playerId).tipoFuoco2

func applicaLivelloMissili(l):
	var nave=instance_from_id(playerId)
	nave.prossimoTipoFuoco2=l

func setPunteggioTerra(p):
	#parmisan:2(3),emmental:3(3),gouda:5(2)
	#soglie: 6,12,20
	punteggioTerra=p
	var punti="Score: "
	if punteggioTerra<6:
		applicaLivelloMissili(0)
		punti=punti+str(punteggioTerra)+"/6"
	elif punteggioTerra<12:
		punti=punti+str(punteggioTerra)+"/12"
		applicaLivelloMissili(1)
	elif punteggioTerra<20:
		punti=punti+str(punteggioTerra)+"/20"
		applicaLivelloMissili(2)
	else:
		punti="Maxed out: go for the moon!"
		applicaLivelloMissili(3)
	
	if HUD!=null:
		HUD.get_node("MarginContainer/CenterContainer/HBoxContainer2/MarginContainer4/Label").text="Score: "+str(punteggioTerra)
		
func setMessage(messaggio,time):
	if HUD!=null:
		messageLifetime=time
		messageTimer=messageLifetime
		message=messaggio
		HUD.get_node("MarginContainer2/CenterContainer/Label").text=messaggio

func addAsteroide(aste):
	asteroidi.append(aste)

func removeAsteroide(aste):
	var temp=[]
	for a in asteroidi:
		if a.get_instance_id()!=aste.get_instance_id():
			temp.append(a)
	asteroidi=temp

func _process(delta):
	messageTimer=messageTimer-delta
	if HUD!=null and messageTimer<=0:
			HUD.get_node("MarginContainer2/CenterContainer/Label").text=""

func avviaFaseFinale():
	pass

func gameOver(ris):
	risultato=ris
	get_tree().change_scene("res://endgame.tscn")

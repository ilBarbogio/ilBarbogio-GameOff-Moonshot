extends Camera

var follow=false

func _ready():
	pass # Replace with function body.

func _process(_delta):
	if follow:
		var event=get_viewport().get_mouse_position()
		var x=event.x
		var y=event.y
		var dX=x-get_viewport().size.x/2
		var dY=y-get_viewport().size.y/2
		if abs(dX)>50:
			var rot=.01
			if abs(dX)>200:
				rot=.02
			if dX>0:
				transform.basis=transform.basis.rotated(Vector3(0,1,0),-rot)
			else:
				transform.basis=transform.basis.rotated(Vector3(0,1,0),rot)
		if abs(dY)>50:
			var rot=.01
			if abs(dY)>200:
				rot=.02
			if dY>0:
				transform.basis=transform.basis.rotated(transform.basis.x,-rot)
			else:
				transform.basis=transform.basis.rotated(transform.basis.x,rot)

func _input(event):
	if event is InputEventMouseButton:
		if follow:
			follow=false
		else:
			follow=true

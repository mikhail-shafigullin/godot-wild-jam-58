extends PartBase

onready var camera: Camera2D = $Camera

var thrusters: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	State.player = self

	camera.make_current()
	_find_thrusters()

func _find_thrusters():
	for c in get_children():
		if c is Thruster:
			thrusters.append(c)

func _input(event):
	if(Input.is_action_just_pressed("ui_accept")):
		for T in thrusters:
			T.fire()

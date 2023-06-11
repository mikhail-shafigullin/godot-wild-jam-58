extends ShipCore
onready var camera: Camera2D = $Camera

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	State.player = self

func _ready():
	is_parts_root = true

	camera.make_current()

func _input(event):
	if(Input.is_action_just_pressed("ui_accept")):
		for T in parts:
			if T is Thruster:
				T.fire()
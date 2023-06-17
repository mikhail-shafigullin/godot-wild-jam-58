extends ShipCore
onready var camera: Camera2D = $Camera

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	State.player = self

func _ready():
	is_parts_root = true
	can_sleep = false
	# can_be_grabbed = false
	set_collision_layer_bit(6, true)
	set_collision_mask_bit(6, true)

	camera.make_current()

func _input(event):
	if(Input.is_action_just_pressed("ui_accept")):
		for p in parts:
			if p is Cannon:
				p.fire()


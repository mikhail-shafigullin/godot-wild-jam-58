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

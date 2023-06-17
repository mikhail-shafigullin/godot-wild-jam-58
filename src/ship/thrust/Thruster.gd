class_name Thruster
extends PartBase

var thruster_force = Vector2(0, 666)
var thruster_is_active: bool = false

func _ready():
	action_controller.bind_action(KEY_SPACE, "on", "off")

func on():
	applied_force = thruster_force.rotated(global_rotation)
	thruster_is_active = true
	
func off():
	applied_force = Vector2.ZERO
	thruster_is_active = false
	
func _physics_process(delta):
	if thruster_is_active:
		core.resource -= 1 * delta
	
func on_part_disabled():
	off()

class_name Thruster
extends PartBase

var thruster_force = Vector2(0, 666)

func _ready():
	set_physics_process(false)
	
func on():
	applied_force = thruster_force.rotated(global_rotation)
	set_physics_process(true)
	
func off():
	applied_force = Vector2.ZERO
	set_physics_process(false)
	
func _physics_process(delta):
	core.resourse -= 1 * delta
	
func on_part_disabled():
	off()

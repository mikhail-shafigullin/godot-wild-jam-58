class_name Thruster
extends PartBase

export var thruster_force: float = 100
export var consuming_rate: float = 5
var thruster_is_active: bool = false

func get_part_data() -> Dictionary:
	var data: Dictionary = {}
	data["price"] = price
	data["mass"] = basic_mass
	data["brake_point"] = breaking_distance
	data["armor"] = armor
	data["softness"] = joints_softness
	data["thruster_force"] = thruster_force * mass / 100

	data["description"] = description
	return data



func _ready():
	action_controller.bind_action(KEY_SPACE, "on", "off")

func on():
	thruster_is_active = true
	
func off():
	applied_force = Vector2.ZERO
	thruster_is_active = false
	
func _physics_process(delta):
	if thruster_is_active:
		var consume = consuming_rate * delta
		if (core.resource - consume) > 0: 
			applied_force = Vector2.UP.rotated(global_rotation) * thruster_force * mass
			core.resource -= consume
		else:
			thruster_is_active = false
			applied_force = Vector2.ZERO
	
func on_part_disabled():
	off()

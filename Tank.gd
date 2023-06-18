extends PartBase


func get_part_data() -> Dictionary:
	var data: Dictionary = {}
	data["price"] = price
	data["mass"] = basic_mass
	data["brake_point"] = breaking_distance
	data["armor"] = armor
	data["softness"] = joints_softness
	data["description"] = description
	data["full mass"] = basic_mass + resource_mass
	return data


export var resource_capacity: float = 100
export var resource_mass: float = resource_capacity*0.2 

func on_part_connect():
	core.resource_max += resource_capacity
	core.tanks.push_back(self)
	set_process(true)

func on_part_disconnect():
	core.resource_max -= resource_capacity
	set_process(false)
	var index = core.tanks.find(self)
	if index != -1:
		core.tanks.remove(index)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

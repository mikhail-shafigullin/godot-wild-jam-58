extends PartBase


export var resource_capacity: float = 100

func on_part_connect():
	core.tanks.push_back(self)
	set_process(true)

func on_part_disconnect():
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

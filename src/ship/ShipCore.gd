class_name ShipCore
extends PartBase

# parts:controllers Dictionary
var parts:		Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_find_thrusters()

func _find_thrusters():
	for c in get_children():
		if c is Thruster:
			parts[c] = PartController.new()

func _part_disconnect(part: PartBase):
	var pt_ctrl = parts.get(part) 
	if parts.erase(part):
		unplug_part(part, pt_ctrl)
		part.on_part_disconnect()

func _part_connect(part: PartBase):
	var pt_ctrl = part.input_controller
	parts[part] = pt_ctrl
	plug_part(part, pt_ctrl)
	part.on_part_connect()

func plug_part(part: PartBase, ctr: PartController):
	pass

func unplug_part(part: PartBase, ctr: PartController):
	pass

func slice_part(part_from: PartBase):
	disconnect_parts(part_from)
	var parent_part: PartBase = part_from.get_parent()
	parent_part.remove_child_part(part_from)
	
	part_from.on_slice()

	#reparent to ship core parent
	var past_global_transform = part_from.global_transform
	part_from.get_parent().remove_child(part_from)
	get_parent().add_child(part_from)
	part_from.global_transform = past_global_transform

func disconnect_parts(start_from_part: PartBase):
	for part in start_from_part.children_parts:
		disconnect_parts(part)
		_part_disconnect(part)

	_part_disconnect(start_from_part)

func connect_parts(start_from_part: PartBase):
	for part in start_from_part.children_parts:
		connect_parts(part)
		_part_connect(part)
	
	_part_connect(start_from_part)

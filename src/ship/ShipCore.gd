class_name ShipCore
extends PartBase

# parts:controllers Dictionary
var parts:		Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _part_disconnect(part: PartBase):
	var pt_ctrl = parts.get(part) 
	if parts.erase(part):
		unplug_part(part, pt_ctrl)

func _part_connect(part: PartBase):
	var pt_ctrl = part.input_controller
	parts[part] = pt_ctrl
	plug_part(part, pt_ctrl)

func plug_part(part: PartBase, ctr: PartController):
	part.on_part_connect()

func unplug_part(part: PartBase, ctr: PartController):
	part.on_part_disconnect()

# slice will keep children and remove from parent
func slice_part(part: PartBase):
	disconnect_parts(part)
	var parent = part.get_parent()
	if parent is PartBase:
		parent.remove_child_part(part)
	
	part.on_slice()

	#reparent to ship core parent
	var past_global_transform = part.global_transform
	parent.remove_child(part)
	core.get_parent().add_child(part)
	part.global_transform = past_global_transform

	fix_joints(part)
 
func weld_part(part: PartBase, weld_to: PartBase):
	var temp_transform = part.global_transform
	part.get_parent().remove_child(part)
	weld_to.add_child(part)
	part.global_transform = temp_transform
	weld_to.children_parts.append(part)
	
	if part_has_access_to_core(part):
		connect_parts(part)

func part_has_access_to_core(part: PartBase) -> bool:
	var parent = part.get_parent()
	if parent is PartBase:
		if parent == self:
			return true
		else:
			return part_has_access_to_core(parent)	
	else:
		return false

func fix_joints(part_from: PartBase):
	for c in part_from.children_parts:
		fix_joints(c)
		c.fix_joints_path()
	part_from.fix_joints_path()

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

func repair_part(part: PartBase):
	part.on_repair()

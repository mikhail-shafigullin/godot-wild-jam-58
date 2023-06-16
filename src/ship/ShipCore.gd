class_name ShipCore
extends PartBase

# parts:controllers Dictionary
var parts:	Array = []
var resource : float = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _part_disconnect(part: PartBase):
	if parts.has(part):
		unplug_part(part)

func _part_connect(part: PartBase):
	plug_part(part)

func plug_part(part: PartBase):
	parts.append(part)
	part.on_part_connect()

func unplug_part(part: PartBase):
	part.on_part_disconnect()
	var index = parts.find(part)
	if index != -1:
		parts.remove(index)

# slice will keep children and remove from parent
func slice_part(part: PartBase):
	if part == self:
		print('game over')
		return
	if not part.part_is_connected:
		return
	part.on_slice()
	disconnect_parts(part)

	var parent = part.get_parent()
	if parent is PartBase:
		parent.sleeping = false
		if parent.has_part_in_children(part):
			parent.remove_child_part(part)
	
	#reparent to ship core parent
	var past_global_transform = part.global_transform
	parent.remove_child(part)
	core.get_parent().add_child(part)
	part.global_transform = past_global_transform
	
	if parent is RigidBody2D:
		parent.sleeping = false
	
	fix_joints(part)
 
func weld_part(part: PartBase, weld_to: PartBase):
	var temp_transform = part.global_transform
	part.get_parent().remove_child(part)
	weld_to.add_child(part)
	part.global_transform = temp_transform
	weld_to.children_parts.append(part)
	weld_to.sleeping = false
	part.sleeping = false
	part.on_weld()
	
	if part_has_access_to_core(part):
		connect_parts(part)

# rewrite move from the top
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
	# if parts.has(start_from_part):
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

class_name ShipCore
extends PartBase

var parts:		Dictionary = {}

enum PartsTypes { THRUSTER, COLLECTOR, UTIL }

class PartController:
	var part_type
	var display_name: String = "part"
	var key_bind: InputEventAction

# Called when the node enters the scene tree for the first time.
func _ready():
	_find_thrusters()

func _find_thrusters():
	for c in get_children():
		if c is Thruster:
			parts[c] = PartController.new()

func on_part_destruction(part: PartBase):
	var pt_ctrl = parts.get(part) 
	if parts.erase(part):
		unplug_part(pt_ctrl)
		part.on_destroy()

func plug_part(ctr: PartController):
	pass

func unplug_part(ctr: PartController):
	pass

func slice_part(part_from: PartBase):
	destroy_part(part_from)

	part_from.on_slice()

	#reparent to ship core parent
	var past_global_transform = part_from.global_transform
	part_from.get_parent().remove_child(part_from)
	get_parent().add_child(part_from)
	part_from.global_transform = past_global_transform

func destroy_part(start_from_part: PartBase):
	for part in start_from_part.children_parts:
		destroy_part(part)
		on_part_destruction(part)

	on_part_destruction(start_from_part)

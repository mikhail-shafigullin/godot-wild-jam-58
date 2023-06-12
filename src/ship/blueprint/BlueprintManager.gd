class_name BlueprintManager
extends Control



var active_part: PartBase

var holding_part: PartBase



var grab_layer_memory: int = 0

const grab_hover_layers: int = 16



func _ready():
	State.bp_manager = self



func _process(delta):
	if holding_part:
		holding_part._scan_probes()
		holding_part.global_position = get_global_mouse_position()



func click_on_part(part: PartBase):
	if holding_part == part:
		release_part(part)
		free_active_part()
	else:
		grab_part(part)



func free_active_part():
	if holding_part:
		release_part(holding_part)
	if active_part:
		deactivate_part(active_part)



func activate_part(part: PartBase):
	if active_part:
		deactivate_part(active_part)
	active_part = part
	part.on_bp_activate()



func deactivate_part(part: PartBase):
	active_part = null
	part.on_bp_deactivate()

func grab_part(part: PartBase):
	free_active_part()

	var part_parent = part.get_parent()
	if part_parent is PartBase and !part.is_parts_root:
		part.part_slice()

	part.rotation = 0.0
	part.position = get_global_mouse_position()
	holding_part = part
	part.on_grab()

func release_part(part: PartBase):
	holding_part = null
	part.on_release()

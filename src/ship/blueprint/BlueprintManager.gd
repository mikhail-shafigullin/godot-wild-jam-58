class_name BlueprintManager
extends Control

var active_part: PartBase
var holding_part: PartBase
var grab_layer_memory: int = 0
const grab_hover_layers: int = 16
var rotation_target: float = 0
var rotation_step: float = 0

func _ready():
	State.bp_manager = self

func _process(delta):
	if holding_part != null:
		holding_part._scan_probes()
		holding_part.global_position = holding_part.get_global_mouse_position()

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed:
			var part = get_part_under_cursor()
			if part:
				click_on_part(part)

func get_part_under_cursor() -> PartBase:
	var ray_caster: RayCast2D = RayCast2D.new()
	var scene_root = get_tree().root
	var _root
	for n in scene_root.get_children():
		if n is Node2D:
			_root = n
			break
	if not _root:
		print("cant cast ray here")
		return null
	
	_root.add_child(ray_caster)
	ray_caster.collision_mask = 256
	ray_caster.global_position = _root.get_global_mouse_position()
	ray_caster.cast_to = Vector2(-5,-10)
	ray_caster.force_raycast_update()

	var last_hit = ray_caster.is_colliding()
	var hits = []
	while last_hit != null:
		last_hit = ray_caster.get_collider()
		if last_hit:
			ray_caster.add_exception(last_hit)
			if last_hit is PartBase:
				hits.append(last_hit)
				print("hit :%s Z: %d"%[last_hit, last_hit.z_index])
			ray_caster.force_raycast_update()
	
	ray_caster.queue_free()
	if not hits.empty():
		var best_hit = hits[0]
		for hit in hits:
			if hit.z_index > best_hit.z_index:
				best_hit = hit
		print("best hit :%s Z: %d"%[best_hit, best_hit.z_index])
		
		return best_hit
	else:
		return null

func click_on_part(part: PartBase):
	print("CLICK")
	if holding_part:
		free_active_part()
	else:
		grab_part(part)

func free_active_part():
	if holding_part:
		holding_part.z_index = 0
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

func rotate_right():
	rotation_target += rotation_step

func rotate_left():
	rotation_target += rotation_step
	
func rotation_add(amount):
	rotation_target += amount

func grab_part(part: PartBase):
	free_active_part()
	part.z_index = 999
	rotation_target  = 0

	var part_parent = part.get_parent()
	if part_parent is PartBase and !part.is_parts_root:
		part.part_slice()

	part.rotation = 0.0
	part.position = get_global_mouse_position()
	holding_part = part
	part.on_grab()

func release_part(part: PartBase):
	print("release part")
	part.z_index = 0
	holding_part = null
	if part.can_be_build():
		part.build()
	part.on_release()

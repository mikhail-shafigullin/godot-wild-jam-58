extends Panel

const sb_active = preload("res://src/ship/blueprint/cursor_active_sbox.tres")
const sb_normal = preload("res://src/ship/blueprint/cursor_normal_sbox.tres")

export var interpolation_speed: float = 0.2
export var cursor_size: float = 10
onready var tween = $"Tween"
var follow: bool = true
var follow_target: Node2D
onready var root_scene = State.get_root_scene()
onready var tool_panel: HBoxContainer = $"../ToolPanel"
var tool_panel_offset: Vector2 = Vector2(-20, 0)
var timer: Timer
var pos_offset: Vector2


func _ready():
	mark_normal()
	# lock_on(Vector2(150,100), Vector2(150, 150))
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	add_child(timer)

func set_cursor_position(new_center: Vector2, _rotation: float = 0):
	rect_global_position = new_center - rect_size/2 + pos_offset
	rect_pivot_offset = rect_size*0.5
	rect_rotation = _rotation 
	if (new_center.x > get_viewport().size.x * 0.5):
		tool_panel_offset = Vector2(-tool_panel.rect_size.x, 0)
	else:
		tool_panel_offset = Vector2(-20,0)
	if tool_panel.visible:
		set_panel_position()

func set_panel_position():
	tool_panel.rect_global_position = rect_global_position + rect_size + tool_panel_offset

func _process(delta):
	if State.player:
		pos_offset = State.player.get_canvas_transform().origin - get_canvas_transform().origin
		if follow:
			if follow_target:
				if follow_target is PartBase:
					set_cursor_position(follow_target.get_part_global_position(),
										follow_target.get_part_global_rotation())
				else:
					set_cursor_position(follow_target.global_position,
										follow_target.global_rotation_degrees)
			else:
				set_cursor_position(root_scene.get_global_mouse_position(),
									root_scene.global_rotation_degrees)
								
func lock_on(node, activate = true):
	if activate:
		mark_active()
	follow = true
	follow_target = node
	var target_size: Vector2 = follow_target.get_part_size()
	rect_size = target_size + Vector2(16,16)
	set_cursor_size(target_size)

func focus_on_part(part: PartBase, activate = true):
	mark_normal()
	tween.stop_all()	
	# rect_size = Vector2.ZERO
	# if follow_target:
	# 	var prev_center
	# 	if follow_target is PartBase:
	# 		prev_center = follow_target.get_part_global_position() + pos_offset - follow_target.get_part_size()*0.5
	# 	else:
	# 		prev_center = follow_target.global_position
	# 	rect_global_position = prev_center

	if not get_tree().paused:
		lock_on(part, activate)
		return

	follow = false
	follow_target = part

	var part_size = part.get_part_size()
	tween.interpolate_property(self, "rect_global_position",
		rect_global_position, part.get_part_global_position() + pos_offset - part_size*0.5, interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rect_rotation",
		rect_rotation, part.get_part_global_rotation(), interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rect_pivot_offset",
		rect_pivot_offset, part_size*0.5, interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	set_cursor_size(part_size)
	
	timer.stop()
	timer.wait_time = interpolation_speed
	timer.start()
	
func _on_timer_timeout():
	if (follow_target):
		lock_on(follow_target)
		mark_active()
		timer.stop()

func mark_active():
	add_stylebox_override("panel", sb_active)
	tool_panel.show()

func set_cursor_size(size: Vector2):
	tween.interpolate_property(self, "rect_size",
		rect_size, size, interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func mark_normal():
	set_cursor_size(Vector2(cursor_size, cursor_size))	
	add_stylebox_override("panel", sb_normal)
	tool_panel.hide()
	follow = true
	follow_target = null

func get_part_under_cursor() -> PartBase:
	var ray_caster: RayCast2D = RayCast2D.new()
	var _root = State.get_root_scene()
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

func _on_tween_all_completed():
	pass

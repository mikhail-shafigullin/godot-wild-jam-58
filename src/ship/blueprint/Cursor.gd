extends Panel

const sb_active = preload("res://src/ship/blueprint/cursor_active_sbox.tres")
const sb_normal = preload("res://src/ship/blueprint/cursor_normal_sbox.tres")

export var interpolation_speed: float = 1
export var cursor_size: float = 10
onready var tween = $"Tween"
var follow: bool = true
var follow_target: Node2D
onready var root_scene = State.get_root_scene()
onready var tool_panel = $ToolPanel
export var tool_panel_offset: Vector2 = Vector2(-20, 0)

func _ready():
	mark_normal()
	# focus_on(Vector2(150,100), Vector2(150, 150))

func set_cursor_position(new_center: Vector2, _rotation: float = 0):
	rect_global_position = new_center - rect_size/2
	tool_panel.rect_position = rect_size + tool_panel_offset
	rect_rotation = _rotation 

func _process(delta):
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

func focus_on(node):
	follow = true
	follow_target = node

	var _global_position = node.global_position
	var size = Vector2.ZERO
	tween.interpolate_property(self, "rect_global_position",
		rect_global_position, _global_position, interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	# tween.interpolate_property(self, "rect_pivot_offset",
	# 	rect_pivot_offset, size*0.5, interpolation_speed,
	# 	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	set_cursor_size(follow_target.get_part_size())
	

	tween.start()

func mark_active():
	add_stylebox_override("panel", sb_active)
	follow = false

func set_cursor_size(size: Vector2):
	tween.interpolate_property(self, "rect_size",
		rect_size, size, interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func mark_normal():
	set_cursor_size(Vector2(cursor_size, cursor_size))	
	add_stylebox_override("panel", sb_normal)
	follow = true
	follow_target = null


func _on_tween_all_completed():
	pass

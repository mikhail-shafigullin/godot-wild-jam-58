class_name BlueprintManager
extends Control

onready var bp_cursor = $Cursor

var active_part: PartBase
var holding_part: PartBase
var grab_layer_memory: int = 0
const grab_hover_layers: int = 16
var rotation_target: float = 0
var rotation_step: float = 0
var vp_offset: Vector2

func _ready():
	State.bp_manager = self

func _process(delta):
	# vp_offset = State.player.get_canvas_transform().origin
	# rect_global_position = vp_offset
	if holding_part != null:
		holding_part._scan_probes()
		holding_part.global_position = holding_part.get_global_mouse_position()
		holding_part.rotation_degrees = rotation_target

func _on_gui_input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			print("pause")
			get_tree().paused = !get_tree().paused
	
	if event is InputEventMouseMotion:
		if holding_part:
			pass

	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				if holding_part:
					release_part(holding_part)
				else:
					bp_cursor.mark_normal()
					var part = bp_cursor.get_part_under_cursor()
					if part and part != active_part:
						click_on_part(part)
					else:
						free_active_part()
			if event.button_index == BUTTON_RIGHT:
				pass
		


func click_on_part(part: PartBase):
	print("CLICK")
	activate_part(part)
	bp_cursor.focus_on_part(part)


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
	bp_cursor.mark_normal()

func rotate_right():
	rotation_target += rotation_step

func rotate_left():
	rotation_target += rotation_step
	
func rotation_add(amount):
	rotation_target += amount

func stabilize_part(part: PartBase):
	for p in part.children_parts:
		stabilize_part(p)
	
	part.sleeping = false
	part.linear_velocity = Vector2.ZERO
	part.angular_velocity = 0


func grab_part(part: PartBase):
	if !part.can_be_grabbed: 
		return
	stabilize_part(part)

	free_active_part()
	part.z_index = 999
	rotation_target = 0
	bp_cursor.lock_on(part, false)

	var part_parent = part.get_parent()
	if part_parent is PartBase and !part.is_parts_root:
		part.part_slice()

	part.rotation = 0.0
	part.position = part.get_global_mouse_position()
	holding_part = part
	part.on_grab()

func release_part(part: PartBase, speed: Vector2 = Vector2.ZERO):
	print("release part")
	bp_cursor.mark_normal()
	stabilize_part(part)
	# part.mode = RigidBody2D.MODE_RIGID
	part.z_index = 0
	holding_part = null

	print("trying to build %s"%part.name)
	if (part.best_part):
		print("build target is %s"%part.best_part.name)
	if part.can_be_build():
		part.build()
	part.on_release()


func _on_Grab_pressed():
	if active_part:
		grab_part(active_part)

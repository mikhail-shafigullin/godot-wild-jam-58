class_name BlueprintManager
extends Control
signal bp_paused

onready var bp_cursor = $Cursor

var active_part: PartBase
var holding_part: PartBase
var grab_layer_memory: int = 0
const grab_hover_layers: int = 16
var rotation_target: float = 0
var rotation_step: float = 15
var vp_offset: Vector2

var highlighted_part: PartBase = null

func _ready():
	State.bp_manager = self

func _process(_delta):
	# vp_offset = State.player.get_canvas_transform().origin
	# rect_global_position = vp_offset
	if holding_part != null:
		holding_part._scan_probes()
		holding_part.global_position = holding_part.get_global_mouse_position()
		holding_part.rotation_degrees = rotation_target

func _input(event):
	if event.is_action_pressed("bp_rotate_right"):
		rotation_target -= rotation_step
	if event.is_action_pressed("bp_rotate_left"):
		rotation_target += rotation_step

func buy_part(path: String, price: float):
	if State.scrap >= price: 
		State.scrap -= price
		State.ui.shop.hide_shop()
		var new_part_res: Resource = load(path)
		if new_part_res:
			var new_part = new_part_res.instance()	
			State.get_root_scene().add_child(new_part)
			grab_part(new_part)	

func pause_game_toggle():
	get_tree().paused = !get_tree().paused
	emit_signal("bp_paused")		
	if get_tree().paused:
		print("pause")

	
onready var grab_button = $ToolPanel/Grab
func _on_gui_input(event: InputEvent):
	if State.world.player_out:
		grab_button.disabled = true
	# if event is InputEventKey:
	# 	if event.pressed and event.scancode == KEY_ESCAPE:

	
	if event is InputEventMouseMotion:
		if holding_part:
			pass

	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				if holding_part:
					free_active_part()
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
	grab_button.disabled = !part.can_be_grabbed
	bp_cursor.focus_on_part(part)


func free_active_part():
	if holding_part:
		holding_part.z_index = 0
		release_part(holding_part)
	if active_part:
		deactivate_part(active_part)
	if highlighted_part:
		_highlight_new_part(null)

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
	rotation_target = (int(part.global_rotation_degrees) / int(rotation_step)) * rotation_step
	bp_cursor.lock_on(part, false)

	var part_parent = part.get_parent()
	if part_parent is PartBase and !part.is_parts_root:
		part.part_slice()

	part.position = part.get_global_mouse_position()
	holding_part = part
	holding_part.connect("on_best_part_change", self, "_highlight_new_part")
	part.on_grab()

func _highlight_new_part(part: PartBase = null):
	if highlighted_part:
		highlighted_part.on_bp_highlight_end()
	
	highlighted_part = part
	if part:
		part.on_bp_highlight_start()

func release_part(part: PartBase):
	print("release part")
	State.ui.shop.show_shop()
	bp_cursor.mark_normal()
	stabilize_part(part)
	# part.mode = RigidBody2D.MODE_RIGID
	part.z_index = 0
	holding_part.disconnect('on_best_part_change', self, "_highlight_new_part")
	holding_part = null
	if not get_tree().paused:
		part.apply_impulse(Vector2.ZERO, Vector2.ONE * randf()*part.mass*16)
	part.on_release()
	if (part.best_part):
		print("build target is %s"%part.best_part.name)
	if part.can_be_build():
		part.build()
	else:
#		part.set_collision_layer_bit(0, true)
		pass


func _on_Grab_pressed():
	if active_part:
		grab_part(active_part)


var waiting_for_part: PartBase
var wait_face
func _on_Controls_pressed():
	if active_part:
		wait_face = active_part.get_popup_actions()
		State.ui.show_popup(wait_face, {})
		wait_face.setup_for(active_part.action_controller)
		State.ui.popup.connect("visibility_changed", self, "on_popup_close")
		waiting_for_part = active_part

func on_popup_close():
	if waiting_for_part:
		State.ui.popup.disconnect("visibility_changed", self, "on_popup_close")
		waiting_for_part.action_controller = wait_face.get_controller()
		wait_face.queue_free()
		waiting_for_part.part_reconnect()
		
	

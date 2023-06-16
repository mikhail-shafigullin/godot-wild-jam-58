class_name PartBase

extends RigidBody2D
signal on_best_part_change 

# Disconnecting / Connecting 		will NOT change ship structure
# Slice 		/ 	Weld 			will change ship structure

#TEMP
onready var core = State.player
#TEMP


# { keycode : [{ pressed : [functions, ...]} , released : [functions, ...] ] }
var input_map: Dictionary = {}

export var init_health: float = 100
onready var health = init_health
export var armor: float = 1
export var armor_weak: float = -1
export var breaking_distance: float = 10
export var can_be_grabbed: bool = true
export var joints_softness: float = 0.0
export var part_visual_size: Vector2 = Vector2(10,10)
export(NodePath) var main_sprite_path 
export(Texture) var item_icon
onready var main_sprite: Sprite 

const popup_actions: Resource		 = preload("res://src/interface/pop_faces/PUFPartActions.tscn")
var   custom_popup_actions: Resource = null
const popup_menu_face: Resource 	 = null
var   custom_popup_menu: Resource    = null

# array of PartJoints
# Joins will connect only to parent
var part_joints: Array = []
var is_parts_root: bool
var part_is_active: bool
var part_is_connected: bool = false

class PartJoint:
	var joint_node: Joint2D
	var rest_position: Vector2
	
	func _init(joint = null, rest_pos = null):
		self.joint_node = joint
		self.rest_position = rest_pos

# Array of PartBase children
var children_parts: Array = []


var action_controller: ActionController = ActionController.new()


func _init():
	# set_collision_layer_bit(0, false)
	set_collision_layer_bit(8, true)
	#set_collision_mask_bit(8, true)

func _ready():
	if (main_sprite_path):
		main_sprite = get_node(main_sprite_path)
	_find_probes()

func _physics_process(delta):
	if (health > 0 and not is_parts_root):
		_update_joints()

# Base functions
func part_slice():
	if part_is_connected:
		core.slice_part(self) 

func part_weld(to_part: PartBase):
	core.weld_part(self, to_part)

func part_connect():
	core.connect_parts(self)

func part_disconnect():
	core.disconnect_parts(self)

func part_repair():
	core.repair_part(self)

func part_reconnect():
	if part_is_connected:
		part_disconnect_input()
		part_connect_input()	

# Blueprint functions
var probes: Array
var active_probes: Array
var best_part: PartBase
onready var best_score: float = min_joint_score
export var max_joint_score: float = 111
export var min_joint_score: float = 0.1


func show_probes():
	for p in probes:
		p.show()

func hide_probes():
	for p in probes:
		p.hide()

func remove_child_part(part: PartBase):
	if children_parts.has(part):
		var index = children_parts.find(part)
		children_parts.remove(index)

func can_be_build() -> bool:
	_scan_probes()
	if best_part == null or best_part == self:
		return false
	#recursion check
	var is_recursive_build = best_part.has_part_in_children(self) or best_part.has_part_in_parents(self)
	return !is_recursive_build 
	
func build():
	if !best_part:
		print("cant find part no building for today")
		return
	print("build score: %f"% best_score)
	z_index = best_part.z_index+1
	best_part.sleeping = false
	best_part.set_collision_layer_bit(0, false)

	part_weld(best_part)	
	_create_joints()
	if not children_parts.empty():
		core.fix_joints(self)

func _find_probes():
	for c in get_children():
		if c is BPProbe:
			probes.append(c)
			c.hide()

var old_best_part: PartBase
func _scan_probes():
	var nodes_probes: 		Dictionary = {}
	var nodes_score:		Dictionary = {}
	old_best_part = best_part
	best_part = null
	active_probes = []

	for probe in probes:
		probe.mark_inactive()
		var overlap = probe.get_overlapping_bodies()
		for body in overlap:
			if body != self and (body.get_class() == get_class()):
				if nodes_probes.has(body):
					nodes_probes[body].append(probe)
					nodes_score[body] = _score_probes(body.global_position, nodes_probes[body])
				else:
					nodes_probes[body] = [probe]
	
	best_score = min_joint_score
	for m_part in nodes_score:
		if part_score_in_range(nodes_score[m_part], m_part):
			if best_score < nodes_score[m_part]:
				best_score = nodes_score[m_part]
				best_part = m_part
				active_probes = nodes_probes[m_part]

	for probe in active_probes:
		probe.mark_active()
	
	if old_best_part != best_part:
		emit_signal("on_best_part_change", best_part)

func part_score_in_range(score: float, _part: PartBase = self) -> bool:
	return score > _part.min_joint_score and score < _part.max_joint_score
	
func _score_probes(pos:Vector2, _probes: Array) -> float:
	var sum = Vector2()
	for probe in _probes:
		sum += probe.global_position
	var avr_pos: Vector2 = sum / _probes.size()
	
	var dist: float = pos.distance_to(avr_pos)
	return _probes.size() + (1 - 1/(ceil(dist) + 0.01))

func _create_joints():
	for probe in active_probes:
		var joint = PinJoint2D.new()
		joint.softness = joints_softness
		best_part.add_child(joint)
		joint.global_position = probe.global_position
		weld_joint(joint)

func weld_joint(joint:PinJoint2D):
	var new_joint = PartJoint.new(joint, position)
	part_joints.append(new_joint)
	joint.node_a = get_parent().get_path()
	joint.node_b = self.get_path()

func has_part_in_children(part: PartBase) -> bool:
	for c in children_parts:
		if c == part:
			print("%s is a child"% name)
			return true
		else:
			return c.has_part_in_children(part)
	return false

func has_part_in_parents(part: PartBase) -> bool:
	var p = get_parent()
	if p.get_class() == get_class():
		if p == part:
			print("%s is parent to %s"%[p.name, name])
			return true
		else:
			return p.has_part_in_parents(part)
	return false

func get_part_global_position() -> Vector2:
	if main_sprite:
		return main_sprite.global_position
	else:
		return global_position

func get_part_global_rotation() -> float:
	if main_sprite:
		return main_sprite.global_rotation_degrees
	else:
		return global_rotation_degrees

func get_part_size() -> Vector2:
	if main_sprite:
		return main_sprite.texture.get_size() * main_sprite.scale
	else:
		return part_visual_size * scale
	
# Callbacks
func on_slice():
	part_is_connected = false
	for j in part_joints:
		if j.joint_node:
			j.joint_node.queue_free()
	part_joints.clear()
	apply_impulse(Vector2.ZERO, Vector2(randf()*mass,randf()*mass*10))

func on_weld():
	part_repair()
	part_is_connected = true

func on_part_disconnect():
	part_is_active = false
	health = 0
	print("part disconnected")
	part_disconnect_input()

func on_part_connect():
	part_is_active = true
	print("part connected")
	part_connect_input()

func on_repair():
	health = init_health

func on_click():
	pass

func on_grab():
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	show_probes()

func on_release():
	set_collision_mask_bit(0, true)
	hide_probes()

func on_bp_activate():
	modulate = Color.lightseagreen

func on_bp_deactivate():
	modulate = Color.white

func on_bp_highlight_start():
	modulate = Color.lightblue

func on_bp_highlight_end():
	modulate = Color.white

func on_taking_damage():
	if health < 0:
		part_slice()
	

func _update_joints():
	for j in part_joints:
		var distance:float = (position - j.rest_position).length()
		if(distance > breaking_distance):
			part_slice()

func fix_joints_path():
	sleeping = false
	if part_joints.empty():
		return
	
	var new_a: NodePath = part_joints[0].joint_node.get_parent().get_path()
	var new_b: NodePath = get_path()
	for joint in part_joints:
		joint.joint_node.node_a = new_a
		joint.joint_node.node_b = new_b

func get_popup_actions():
	if custom_popup_actions:
		return custom_popup_actions.instance()
	else:
		return popup_actions.instance()

func part_connect_input():
	for dictionary in action_controller.data:
		if dictionary.has(ActionController.ActionType.CALL):
			set_action_call(dictionary.get(ActionController.ActionType.CALL))
		if dictionary.has(ActionController.ActionType.SET):
			set_action_call(dictionary.get(ActionController.ActionType.SET))
			
func part_disconnect_input():
	clear_action_call()

var holding_keys: Dictionary = {}
func _input(event):
	if event is InputEventKey:
		if (input_map.has(event.scancode)):
			if event.pressed:
				if  not holding_keys.has(event.scancode):
					holding_keys[event.scancode] = true
					var func_name = input_map[event.scancode].get("pressed")
					if func_name:
						if has_method(func_name):
							call(func_name)
			else:
				holding_keys.erase(event.scancode)
				var func_name = input_map[event.scancode].get("released")
				if func_name:
					if has_method(func_name):
						call(func_name)
				


# [0   "var"  ,  "value"   ]
func set_part_value( data: Array ):
	if data.size() > 2:
		print("-- fail -- set part value")
		return
	set(data[0], data[1] )


# { keycode : { pressed :[functions], [functions] } }
func set_action_call( data: Array ):
		var scancode: int = data[0]
		var functions: Array = data[1]
		var func_size = functions.size()
		
		if not input_map.has(scancode):
			input_map[scancode] = {}
	
		var map = input_map[scancode]; 
		map["pressed"] = functions[0]
		if func_size > 1:
			map["released"] = functions[1]

func clear_action_call():
	input_map = {}
	# No.
	# for key in data:
		# var scancode = data[0]
		# var functions: Array = data[1]
		# var func_size = functions.size()
		# if input_map.has(scancode):
		# 	if input_map[scancode].has("pressed"):
		# 		input_map[scancode]["pressed"].erase(functions[0])
		# 	if func_size > 1: 
		# 		if input_map[scancode].has("released"):
		# 			input_map[scancode]["released"].erase(functions[1])



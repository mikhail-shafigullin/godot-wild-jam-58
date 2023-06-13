class_name PartBase
extends RigidBody2D

# Disconnecting / Connecting 		will NOT change ship structure
# Slice 		/ 	Weld 			will change ship structure

#TEMP
onready var core = State.player
#TEMP

export var init_health: float = 100
onready var health = init_health
export var part_mass: float = 1
export var armor: float = 1
export var armor_weak: float = -1
export var breaking_distance: float = 10
export var can_be_grabbed: bool = true
export var joints_softness: float = 0
export var part_visual_size: Vector2 = Vector2(10,10)
export(NodePath) var main_sprite_path 
onready var main_sprite: Sprite 

# array of PartJoints
# Joins will connect only to parent
var part_joints: Array = []
var is_parts_root: bool

class PartJoint:
	var joint_node: Joint2D
	var rest_position: Vector2
	
	func _init(joint = null, rest_pos = null):
		self.joint_node = joint
		self.rest_position = rest_pos

# Array of PartBase children
var children_parts: Array = []

enum PartsTypes { FRAME, THRUSTER, COLLECTOR, UTIL }
class PartController:
	var part_type = PartsTypes.FRAME
	var display_name: String = "part"
	var key_bind: InputEventAction = null
	var axis_bind: InputEventAction = null

var input_controller: PartController = PartController.new()

func _init():
	set_collision_layer_bit(0, false)
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
	core.slice_part(self) 

func part_weld(to_part: PartBase):
	core.weld_part(self, to_part)

func part_connect():
	core.connect_parts(self)

func part_disconnect():
	core.disconnect_parts(self)

func part_repair():
	core.repair_part(self)

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

	part_weld(best_part)	
	_create_joints()
	if not children_parts.empty():
		core.fix_joints(self)

func _find_probes():
	for c in get_children():
		if c is BPProbe:
			probes.append(c)
			c.hide()

func _scan_probes():
	var nodes_probes: 		Dictionary = {}
	var nodes_score:		Dictionary = {}
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

func part_score_in_range(score: float, _part: PartBase = self) -> bool:
	return score > _part.min_joint_score and score < _part.max_joint_score
	
func _score_probes(pos:Vector2, probes: Array) -> float:
	var sum = Vector2()
	for probe in probes:
		sum += probe.global_position
	var avr_pos: Vector2 = sum / probes.size()
	
	var dist: float = pos.distance_to(avr_pos)
	return probes.size() + (1 - 1/(ceil(dist) + 0.01))

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
	for j in part_joints:
		if j.joint_node:
			j.joint_node.queue_free()
	part_joints.clear()
	apply_impulse(Vector2.ZERO, Vector2(randf()*mass,randf()*mass))

func on_part_disconnect():
	health = 0

func on_part_connect():
	part_repair()

func on_repair():
	health = init_health

func on_click():
	pass

func on_grab():
	show_probes()

func on_release():
	hide_probes()

func on_bp_activate():
	pass

func on_bp_deactivate():
	pass

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

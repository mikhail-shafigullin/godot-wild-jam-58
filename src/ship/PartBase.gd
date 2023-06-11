class_name PartBase
extends RigidBody2D

#TEMP
onready var core = State.player
#TEMP

export var init_health: float = 100
onready var health = init_health
export var part_mass: float = 1
export var armor: float = 1
export var armor_weak: float = -1
export var breaking_distance: float = 32.1
export var can_be_grabbed: bool = true

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
var is_blueprint: bool = false
var is_grabbed: bool = false
var grab_layer_memory: int = 0
const grab_hover_layers: int = 16
var probes: Array
var active_probes: Array
var best_part: PartBase
export var min_joint_score: float = 0.1

# TODO gamepad support
func click():
	if not is_grabbed:
		if can_be_grabbed:
			grab()
	else:
		release()

func grab():
	grab_layer_memory = collision_layer
	collision_layer = grab_hover_layers

	part_slice()
	show_probes()
	is_grabbed = true
	rotation = 0
	position = get_global_mouse_position()

func release():
	if best_part:
		is_grabbed = false
		build(best_part)
		collision_layer = grab_layer_memory		
		hide_probes()

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

func build(to_part: PartBase):
	part_weld(to_part)	
	_create_joints()
	to_part.children_parts.append(self)

func _find_probes():
	for c in get_children():
		if c is BPProbe:
			probes.append(c)
			c.hide()

func _scan_probes():
	var nodes_probes: 		Dictionary = {}
	var nodes_score:		Dictionary = {}
	best_part = null

	for probe in probes:
		probe.mark_inactive()
		var overlap = probe.get_overlapping_bodies()
		for body in overlap:
			if body != self:
				if nodes_probes.has(body):
					nodes_probes[body].append(probe)
					nodes_score[body] = _score_probes(body.global_position, nodes_probes[body])
				else:
					nodes_probes[body] = [probe]
	
	var best_score: float = min_joint_score
	for m_part in nodes_score:
		if best_score < nodes_score[m_part]:
			best_part = m_part
			active_probes = nodes_probes[m_part]

			for probe in active_probes:
				probe.mark_active()

	
func _score_probes(pos:Vector2, probes: Array) -> float:
	var sum = Vector2()
	for probe in probes:
		sum += probe.global_position
	var avr_pos: Vector2 = sum / probes.size()
	
	var dist: float = pos.distance_to(avr_pos)
	return probes.size()/(dist + 1)

func _create_joints():
	for probe in active_probes:
		var joint = PinJoint2D.new()
		best_part.add_child(joint)
		joint.global_position = probe.global_position
		weld_joint(joint)

func weld_joint(joint:PinJoint2D):
	var new_joint = PartJoint.new(joint, global_position)
	part_joints.append(new_joint)
	joint.node_a = get_parent().get_path()
	joint.node_b = self.get_path()
	
# Callbacks
func on_slice():
	for j in part_joints:
		if j.joint_node:
			j.joint_node.queue_free()
	part_joints.clear()

func on_part_disconnect():
	health = 0

func on_part_connect():
	pass

func on_repair():
	health = init_health

func _ready():
	#confusing placement will override default mass: Remove?
	mass = part_mass

	_find_probes()

func _process(delta):
	if is_grabbed:
		position = get_global_mouse_position()

func _physics_process(delta):
	if is_blueprint and is_grabbed:
		_scan_probes()

	if (health > 0 and not is_parts_root):
		_update_joints()

func _update_joints():
	for j in part_joints:
		var distance:float = (global_position - j.rest_position).length()
		if(distance > breaking_distance):
			part_slice()

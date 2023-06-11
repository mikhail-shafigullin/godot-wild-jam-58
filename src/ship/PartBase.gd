class_name PartBase
extends RigidBody2D

export var init_health: float = 100
onready var health = init_health
export var part_mass: float = 1
export var armor: float = 1
export var armor_weak: float = -1
export var breaking_distance: float = 32.1

export var test_join0: NodePath 
export var test_join1: NodePath 
# array of PartJoints
# Joins will connect only to parent
var part_joints: Array = []
var is_parts_root: bool

# Array of PartBase children
var children_parts: Array = []

#TEMP
onready var core = State.player

func _enter_tree():
	set_collision_layer_bit(0, false)
class PartJoint:
	var joint_node: Joint2D
	var rest_position: Vector2
	
	func _init(joint = null, rest_pos = null):
		self.joint_node = joint
		self.rest_position = rest_pos

# Base functions
func slice():	
	core.slice_part(self) 

func destroy():
	core.destroy_parts(self)

func repair():
	core.repair_part(self)

# Blueprint functions
func weld(joints:Array):
	pass
	
# Callbacks
func on_slice():
	for j in part_joints:
		j.joint_node.queue_free()
	part_joints.clear()

func on_destroy():
	health = 0

func on_repair():
	health = init_health

func _ready():
	#confusing placement will override default mass: Remove?
	mass = part_mass

	#temp remove after blueprint.build() realization
	if (!is_parts_root):
		part_joints = [
			PartJoint.new(get_node(test_join0), position),
			PartJoint.new(get_node(test_join1), position)
		]	

func _physics_process(delta):
	if (health > 0 and not is_parts_root):
		_update_joints()

func _update_joints():
	for j in part_joints:
		var distance:float = (position - j.rest_position).length()
		if(distance > breaking_distance):
			slice()

class_name Cannon
extends PartBase

#export var thrust_multiplying: float = 1
#export var rate_of_fire: float = 1
export var bullet_impulse_value: float = 3000

var bullet_scene = load("res://src/ship/bullet/Bullet.tscn")
onready var axis = $Axis

export var rotation_min_degrees: float = 225
export var rotation_max_degrees: float = 315

# Called when the node enters the scene tree for the first time.
func _ready():
	action_controller.bind_action(KEY_SPACE, 'fire')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if part_is_active:
		if event is InputEventMouseMotion:
			axis.look_at(get_global_mouse_position())
			axis.rotation_degrees = clamp(axis.rotation_degrees, rotation_min_degrees, rotation_max_degrees)
			print("cannon_angle = ", axis.global_rotation)

func fire():
	if core.resource > 0:
		var bullet = bullet_scene.instance()
		bullet.global_transform = global_transform
		bullet.cannon = self
		core.get_parent().add_child(bullet)
#		print("impulse_angle = ", axis.global_rotation)
		var impulse = bullet_impulse_value * Vector2.RIGHT.rotated(axis.global_rotation)
		bullet.apply_impulse(Vector2(), impulse)
		apply_impulse(Vector2(), -impulse)
		core.resource -= 1
	

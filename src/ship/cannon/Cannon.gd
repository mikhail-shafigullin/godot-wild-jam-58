class_name Cannon
extends PartBase

#export var thrust_multiplying: float = 1
#export var rate_of_fire: float = 1
export var bullet_impulse: Vector2 = Vector2(0, -3000)

var bullet_scene = load("res://src/ship/bullet/Bullet.tscn")
onready var axis = $Axis

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if part_is_connected:
		if event is InputEventMouseMotion:
			axis.look_at(get_global_mouse_position())

func fire():
	if core.resource > 0:
		var bullet = bullet_scene.instance()
		bullet.global_transform = global_transform
		bullet.cannon = self
		core.get_parent().add_child(bullet)
		var impulse = bullet_impulse.rotated(global_rotation)
		bullet.apply_impulse(Vector2(), impulse)
		apply_impulse(Vector2(), -impulse)
		core.resource -= 1
	

class_name Thruster
extends PartBase

export var thrust_multiplying: float = 1
export var rate_of_fire: float = 1
export var bullet_impulse: Vector2 = Vector2(0, 3000)

var bullet_scene = load("res://src/ship/bullet/Bullet.tscn")

func fire():
	var bullet = bullet_scene.instance()
	bullet.global_transform = global_transform
	bullet.thruster = self
	core.get_parent().add_child(bullet)
	var impulse = bullet_impulse.rotated(global_rotation)
	bullet.apply_impulse(Vector2(), impulse)
	apply_impulse(Vector2(), -impulse)
	print("fire from %s" %get_name())

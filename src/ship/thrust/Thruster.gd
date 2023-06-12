class_name Thruster
extends PartBase

export var thrust_multiplying: float = 1

func fire():
	var up = Vector2.UP.rotated(global_rotation)
	apply_impulse(Vector2(), up*mass*thrust_multiplying)
	print("fire from %s" %get_name())

class_name Thruster
extends PartBase

func fire():
	var up = Vector2.UP.rotated(global_rotation)
	apply_impulse(Vector2(), up*mass*100)

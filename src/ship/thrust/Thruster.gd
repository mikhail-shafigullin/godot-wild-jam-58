class_name Thruster
extends PartBase

func fire():
    apply_impulse(Vector2(), Vector2(0,-100))
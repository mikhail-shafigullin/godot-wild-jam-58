extends "res://src/ship/thrust/Thruster.gd"

func _ready():
    is_blueprint = true

func _unhandled_input(event):
    if event is InputEventMouseButton:
        if event.pressed:
            grab()


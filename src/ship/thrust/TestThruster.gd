extends "res://src/ship/thrust/Thruster.gd"

func _ready():
    is_blueprint = true

func _on_TestThruster_input_event(viewport:Node, event:InputEvent, shape_idx:int):
    if event is InputEventMouseButton:
        if event.pressed:
            click()


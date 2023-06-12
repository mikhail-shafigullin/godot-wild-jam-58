extends "res://src/ship/thrust/Thruster.gd"


func _on_TestThruster_input_event(viewport:Node, event:InputEvent, shape_idx:int):
	if event is InputEventMouseButton:
		if event.pressed:
			State.bp_manager.click_on_part(self)


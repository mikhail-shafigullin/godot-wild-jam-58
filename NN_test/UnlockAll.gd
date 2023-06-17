extends Node2D

func _exit_tree():
	State.unlocked_parts = State.all_parts
	State.scrap = 99999

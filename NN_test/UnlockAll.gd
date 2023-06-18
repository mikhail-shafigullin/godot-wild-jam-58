extends Node2D

func _ready():
	# State.world.disconnect("player_leave_base", State.bp_manager, "free_active_part")
	pass

func _exit_tree():
	State.unlocked_parts = State.all_parts
	State.scrap = 99999

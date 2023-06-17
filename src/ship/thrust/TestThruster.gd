extends Thruster

func _ready():
	action_controller.bind_action(KEY_SPACE, "_fire_start", "_fire_end")
	action_controller.bind_action(KEY_A, "a_is_pressed")

func _fire_start():
	print("FIRE!!111")

func _fire_end():
	print("no fire :(")

func a_is_pressed():
	print("AAAAAAAAAAAAAAAAAAA is pressed")

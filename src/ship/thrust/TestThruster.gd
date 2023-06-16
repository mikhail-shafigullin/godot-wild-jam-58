extends Thruster

func _ready():
    bind_action(KEY_SPACE, "_fire")

func _fire():
    print("FIRE!!111")
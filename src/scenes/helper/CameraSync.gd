extends Camera2D

func _ready():
	var rc = RemoteTransform2D.new()
	State.player.add_child(rc)
	rc.update_rotation = false
	rc.update_scale = false
	rc.remote_path = get_path()
	pass

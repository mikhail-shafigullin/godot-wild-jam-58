extends Camera2D

func _ready():
	if State.player:
		var rc = RemoteTransform2D.new()
		State.player.add_child(rc)
		rc.remote_path = get_path()
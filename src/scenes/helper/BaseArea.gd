extends Area2D

func _ready():
    connect("body_exited", self, "exit")

func exit(node):
    if node == State.player:
        State.world.player_out()
        queue_free()
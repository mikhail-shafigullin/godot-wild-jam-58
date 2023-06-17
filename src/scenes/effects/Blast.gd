class_name Blast
extends AnimatedSprite


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_degrees = randi() % 360


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()

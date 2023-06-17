extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var eyes: Array;

# Called when the node enters the scene tree for the first time.
func _ready():
	eyes.append_array(get_children());
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

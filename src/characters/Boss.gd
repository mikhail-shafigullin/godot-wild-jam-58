tool
extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var eyes: Array = [];
onready var eyesNode: Node2D = $eyes;
onready var eyesTimer: Timer = $EyesTimer;
onready var closedEyeTimer: Timer = $CloseEyeTimer;
var rand=RandomNumberGenerator.new()

var closedEye;


# Called when the node enters the scene tree for the first time.
func _ready():
	eyes.append_array(eyesNode.get_children());


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_EyesTimer_timeout():
	var index = rand.randi_range(0, eyes.size()-1);
	closedEye = eyes[index];
	eyes[index].set_visible(false);
	closedEyeTimer.start();
	

func _on_CloseEyeTimer_timeout():
	if closedEye :
		closedEye.set_visible(true);
		closedEye = null;

extends Node2D

onready var transitionScreen = $TransitionScreen

func _ready():
	State.sceneManager = self

var temp_scene: Resource

func transition(scene: Resource):
	$TransitionScreen/AnimationPlayer.play("toHide")
	temp_scene = scene

func _on_TransitionScreen_transitioned():
	$CurrentScene.get_child(0).queue_free()
	$CurrentScene.add_child(temp_scene.instance())
	print("sceneTwo")

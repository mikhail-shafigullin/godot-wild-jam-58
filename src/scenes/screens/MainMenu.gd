extends Node2D

const SceneTwo = preload("res://src/scenes/screens/UpgradeScreen.tscn")

func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	State.sceneManager.transition(SceneTwo)

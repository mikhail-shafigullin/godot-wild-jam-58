extends Node2D

const SceneMain = preload("res://src/scenes/OverWorld.tscn")

func _on_Start_Launching_pressed():
	State.sceneManager.transition(SceneMain)

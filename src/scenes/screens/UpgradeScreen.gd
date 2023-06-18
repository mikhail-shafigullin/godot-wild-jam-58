extends Node2D

const SceneMain = preload("res://src/scenes/OverWorld.tscn")

func _ready():
	$AudioStreamPlayer.play()
	
func _on_Start_Launching_pressed():
	State.sceneManager.transition(SceneMain)

func _on_GlobalVolume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

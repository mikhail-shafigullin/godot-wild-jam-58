extends Node

# Тут будут жить наши глобальные штуки
var sceneManager: Node2D;
var player: ShipCore;
var bp_manager: BlueprintManager;

# func _ready():
# 	get_viewport().transparent_bg = true
	
func get_root_scene() -> Node2D:
	if player:
		var player_parent = player.get_parent()
		if player_parent is Node2D:
			return player_parent
		return player;

	for n in get_tree().root.get_children():
		if n is Node2D:
			return n
	return null

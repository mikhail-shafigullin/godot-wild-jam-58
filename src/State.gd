extends Node

# Тут будут жить наши глобальные штуки
var sceneManager: Node2D;
var player: ShipCore;
var bp_manager: BlueprintManager;

func get_root_scene() -> Node2D:
	if sceneManager:
		return sceneManager;

	for n in get_tree().root.get_children():
		if n is Node2D:
			return n
	return null

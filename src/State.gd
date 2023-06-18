extends Node

# Тут будут жить наши глобальные штуки

# player currency
var scrap: float = 322.0

var sceneManager: Node2D;
var player: ShipCore;
var bp_manager: BlueprintManager;
var ui: CanvasLayer;
var world: Node2D
var soundManager: Node2D;
const world_res = preload("res://src/scenes/OverWorld.tscn")
const save_path = "user://game.save"

const unlocks = {
	-111 : "Frame",
	-55555555 : "Collector"
}

#unlocked parts names
var unlocked_parts: Array = ["TestThruster", "Cannon"]
var all_parts: Array = []

func save_game():
	var save_game = File.new()
	save_game.open(save_path, File.WRITE)
	save_game.store_line(to_json([ "unlocked_parts", unlocked_parts] ))
	save_game.store_line(to_json([ "scrap", scrap ]))
	save_game.close()

func load_game():    
	var save_game = File.new()
	if not save_game.file_exists(save_path):
		return # Error! We don't have a save to load.
	
	save_game.open(save_path, File.READ)
	while save_game.get_position() < save_game.get_len():
		var data = parse_json(save_game.get_line())
		match data[0]:
			"unlocked_parts": 
				unlocked_parts = data[1];
				break
			"scrap": 
				unlocked_parts = data[1];
				break
			_: 
				pass
		

	save_game.close()
	

func _ready():
	# get_viewport().transparent_bg = true
	save_game()
	load_game()
	
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

func game_over():
	get_tree().paused = false
	var world_parent = world.get_parent()
	scrap += world.refund_money()
	unlocked_parts += world.get_unlocked_parts()

	save_game()
	world.queue_free()
	world_parent.add_child(world_res.instance())

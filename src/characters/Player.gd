extends ShipCore
onready var camera: Camera2D = $Camera

const kamikaze_scene = preload("res://src/characters/Kamikaze.tscn")
const smart_kamikaze_scene = preload("res://src/characters/SmartKamikaze.tscn")
const shooter_scene = preload("res://src/characters/Shooter.tscn")
const enemy_scenes = [kamikaze_scene, smart_kamikaze_scene, shooter_scene]

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	State.player = self

func zoom_in():
	State.ui.zoom_in()

func zoom_out():
	State.ui.zoom_out()

func _ready():
	action_controller.bind_action(KEY_ESCAPE, "pause_game")
	action_controller.bind_action(KEY_Z, "zoom_in")
	action_controller.bind_action(KEY_X, "zoom_out")
	part_connect_input()
	is_parts_root = true
	can_sleep = false
	# can_be_grabbed = false
#	set_collision_layer_bit(6, true)
#	set_collision_mask_bit(6, true)


	camera.make_current()
	
	if State.soundManager :
		State.soundManager.startLevel(global_position.y)
		State.soundManager.setMusicByYCoord(global_position.y)
		
func _process(delta):
	if State.soundManager :
		State.soundManager.setMusicByYCoord(global_position.y)

func pause_game():
	State.bp_manager.pause_game_toggle()


func _on_SpawnerTimer_timeout():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	$Path2D/PathFollow2D.offset = rng.randf_range(1, 1660)
	
	var enemy = enemy_scenes[randi() % enemy_scenes.size()].instance()
	enemy.global_position = $Path2D/PathFollow2D/Position2D.global_position
	get_parent().add_child(enemy)
	print("%s spawned", enemy.name)

extends ShipCore
onready var camera: Camera2D = $Camera

const enemy = preload("res://src/characters/NPCEnemy.tscn")
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	State.player = self

func _ready():
	action_controller.bind_action(KEY_ESCAPE, "pause_game")
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
	var enemy_node = enemy.instance()
	enemy_node.global_position = $Path2D/PathFollow2D/Position2D.global_position
	get_parent().add_child(enemy_node)
	print("spawn enemy")

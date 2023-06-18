extends KinematicBody2D


const WALK_SPEED = 33
var player_position
var target_position

onready var player:Node2D = get_node("root/Player")

func _ready():
	pass 

func _physics_process(delta):
	if player:
		player_position = player.global_position
		target_position = (player_position - global_position).normalized()
		move_and_slide(target_position * WALK_SPEED)

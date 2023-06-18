class_name Kamikaze
extends EnemyBase


export var reward: float = 35

var player_position: Vector2

func _ready():
	pass 

func _physics_process(delta: float):
	pass

func fight(delta: float):
	player_position = player.global_position
	var dir = (player_position - position).normalized()
	linear_velocity = speed * dir
	look_at(-linear_velocity)
	pass

func die():
	print("%s is dead. Reward: %s"% [ name, reward])
	applied_force = Vector2.ZERO
	applied_torque = deg2rad(360 * randf() - 180) * 100 * mass
	State.world.score += reward

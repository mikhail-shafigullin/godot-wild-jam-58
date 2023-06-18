class_name Shooter
extends EnemyBase

export var reward: float = 100

var player_position: Vector2
var target_position: Vector2
var target_offset: Vector2
var time_past: float = 0

func _ready():
	target_offset = Vector2.UP.rotated(deg2rad(210*(randf()-0.5))) * (300 + 700*(randf()))
	pass 

func _physics_process(delta: float):
	pass

func fight(delta: float):
	time_past += (randf() + 0.5) * delta
	player_position = player.global_position
	target_position = (player_position - global_position + target_offset + (Vector2(0,-speed)*sin(time_past) + (Vector2(speed, 0)*cos(time_past)))).normalized()
	applied_force = (target_position * speed * mass)
	applied_torque = -rotation*mass
	shoot(player_position)
	pass

func shoot(position: Vector2):
	pass

func die():
	print("%s is dead. Reward: %s"% [ name, reward])
	State.world.score += reward

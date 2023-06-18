class_name SmartKamikaze
extends EnemyBase

export var reward: float = 35

onready var sq_speed = speed * speed

var player_position: Vector2
var player_linear_velocity: Vector2

func _ready():
	pass 

func _physics_process(delta: float):
	pass

func fight(delta: float):
	player_position = player.global_position
	player_linear_velocity = player.linear_velocity
	
	var u = player_position - position
	var u2 = u.dot(u)
	var p = u.dot(player_linear_velocity)
	var p2 = p * p
	var d = sq_speed - player_linear_velocity.dot(player_linear_velocity)
	var prediction_parameter = (p + sqrt(p2 + u2 * d)) / d
	
	linear_velocity = u / prediction_parameter + player_linear_velocity

func die():
	print("%s is dead. Reward: %s"% [ name, reward])
	applied_force = Vector2.ZERO
	applied_torque = deg2rad(360 * randf() - 180) * 100 * mass
	State.world.score += reward

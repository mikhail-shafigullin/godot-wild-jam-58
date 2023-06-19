class_name Shooter
extends EnemyBase

export var reward: float = 100

var bullet_scene = load("res://src/ship/bullet/ShooterBullet.tscn")

var player_position: Vector2
var target_position: Vector2
var target_offset: Vector2
var time_past: float = 0
var shooting_delay: float = 3
var shooting_delay_counter: float = 0

func _ready():
	target_offset = Vector2.UP.rotated(deg2rad(210*(randf()-0.5))) * (300 + 700*(randf()))
	pass 

func _physics_process(delta: float):
	pass

func on_taking_damage(damage: float):
	.on_taking_damage(damage)

func fight(delta: float):
	time_past += (randf() + 0.5) * delta
	player_position = player.global_position
	target_position = (player_position - global_position + target_offset + (Vector2(0,-speed)*sin(time_past) + (Vector2(speed, 0)*cos(time_past)))).normalized()
	applied_force = (target_position * speed * mass)
	applied_torque = -rotation*mass
	
	shooting_delay_counter += delta
	if shooting_delay_counter > shooting_delay:
		shooting_delay_counter = 0
		shoot(player_position)


func shoot(position: Vector2):
	var bullet = bullet_scene.instance()
	bullet.global_transform = global_transform
	bullet.linear_velocity = linear_velocity
	get_parent().add_child(bullet)
	var impulse = 666 * (position - global_position).normalized()
	bullet.apply_impulse(Vector2(), impulse)
	apply_impulse(Vector2(), -impulse)

func die():
	applied_force = Vector2.ZERO
	applied_torque = deg2rad(360 * randf() - 180) * 100 * mass
	State.world.score += reward
	.die()

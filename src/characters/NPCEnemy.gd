extends RigidBody2D


const WALK_SPEED = 333
var player_position
var target_position
var target_offset: Vector2
var time_past: float = 0
export var health_max: float = 300
onready var health: float = health_max
var award: float = 100
var alive: bool = true

onready var player:Node2D = State.player

func _ready():
	target_offset = Vector2.UP.rotated(deg2rad(210*(randf()-0.5))) * (300 + 700*(randf()))
	pass 

func _physics_process(delta: float):
	if player and alive:
		time_past += (randf() + 0.5) * delta
		player_position = player.global_position
		target_position = (player_position - global_position + target_offset + (Vector2(0,-WALK_SPEED)*sin(time_past) + (Vector2(WALK_SPEED, 0)*cos(time_past)))).normalized()
		applied_force = (target_position * WALK_SPEED * mass)
		applied_torque = -rotation*mass

		get_damage( health_max * delta )

		if (randf() < 0.05):
			target_offset = Vector2.UP.rotated(deg2rad(180*(randf()-0.5))) * (300 + 700*(randf()))
	
	if (global_position.y > 500):
		queue_free() 


func get_damage(damage: float):
	health -= damage
	if health <= 0:
		death()

func death():
	print("%s is dead: %s"% [ name, award])
	alive = false
	applied_force = Vector2.ZERO
	applied_torque = deg2rad(360 * randf() - 180) * 100 * mass
	State.world.score += award

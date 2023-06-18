class_name EnemyBase
extends RigidBody2D

onready var player:Node2D = State.player

export var health: float = 100
export var speed: float = 333

var is_alive: bool = true

func _ready():
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_bit(6, true)
	pass 

func _physics_process(delta: float):
	if player:
		if is_alive:
			fight(delta)
		if (abs(player.position.x - position.x) + abs(player.position.y - position.y) > 777):
			queue_free()

func fight(delta: float):
	pass

func on_taking_damage(damage: float):
	health -= damage
	if health <= 0:
		die()

func die():
	is_alive = false
#	applied_force = Vector2.ZERO
#	applied_torque = deg2rad(360 * randf() - 180) * 100 * mass

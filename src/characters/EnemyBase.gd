class_name EnemyBase
extends RigidBody2D

onready var player:Node2D = State.player
onready var animated_sprite: AnimatedSprite = $AnimatedSprite

export var health: float = 100
export var speed: float = 100

var is_alive: bool = true
var is_boss: bool = false

func _ready():
	player = State.player
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_bit(6, true)
	pass 

func _physics_process(delta: float):
	if player:
		if is_alive:
			fight(delta)
		if (abs(player.position.x - position.x) + abs(player.position.y - position.y) > 2000):
			if !is_boss :
				queue_free()

func fight(delta: float):
	pass

func on_taking_damage(damage: float):
	print("damage1: " + str(damage));
	print("health1: " + str(health));
	health -= damage
	if health <= 0:
		die()

func die():
	is_alive = false
	collision_layer = 0
	collision_mask = 0
	animated_sprite.stop()
	animated_sprite.set_modulate(Color(0.5, 0.5, 0.5))


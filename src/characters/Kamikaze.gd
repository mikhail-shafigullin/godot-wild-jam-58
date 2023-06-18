class_name Kamikaze
extends EnemyBase


export var reward: float = 35

var blast_scene = load("res://src/scenes/effects/Blast.tscn")

var player_position: Vector2

func _ready():
	set_collision_mask_bit(1, true)

func _physics_process(delta: float):
	pass

func on_taking_damage(damage: float):
	.on_taking_damage(damage)

func fight(delta: float):
	player_position = player.global_position
	var dir = (player_position - position).normalized()
	linear_velocity = speed * dir
	look_at(-linear_velocity)
	pass

func die():
	applied_force = Vector2.ZERO
	applied_torque = deg2rad(360 * randf() - 180) * 100 * mass
	State.world.score += reward
	.die()


func _on_Kamikaze_body_entered(body):
	var blast = blast_scene.instance()
	blast.global_transform = global_transform
	get_parent().add_child(blast)
	queue_free()

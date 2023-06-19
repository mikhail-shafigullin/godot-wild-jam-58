class_name ShooterBullet
extends RigidBody2D


var blast_scene = load("res://src/scenes/effects/Blast.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_taking_damage(damage: float):
	queue_free()

func _on_ShooterBullet_body_entered(body):
	var blast = blast_scene.instance()
	blast.global_transform = global_transform
	get_parent().add_child(blast)
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

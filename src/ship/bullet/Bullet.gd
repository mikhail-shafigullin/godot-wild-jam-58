class_name Bullet
extends RigidBody2D


export var damage: float = 20
var cannon: Cannon

var blast_scene = load("res://src/scenes/effects/Blast.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Bullet_body_entered(body):
	var blast = blast_scene.instance()
	blast.global_transform = global_transform
	cannon.core.get_parent().add_child(blast)
	for b in $EffectArea.get_overlapping_bodies():
		if b is PartBase:
			b.health -= damage
			print(b.health)
			b.on_taking_damage()
	queue_free()


func _on_ActivationTimer_timeout():
	# $CollisionShape2D.set_deferred("disabled", false)
	if not is_connected("body_entered", self, "_on_Bullet_body_entered"):
		connect('body_entered', self, '_on_Bullet_body_entered')


func _on_Bullet_body_exited(body):
	if body == cannon:
		connect('body_entered', self, '_on_Bullet_body_entered')

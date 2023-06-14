extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var thruster : Thruster

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Bullet_body_entered(body):
	# $EffectArea/CollisionShape2D.set_deferred("disabled", false)
	for b in $EffectArea.get_overlapping_bodies():
		if b is PartBase:
			b.health -= 20
			print(b.health)
			b.on_taking_damage()
	queue_free()



func _on_ActivationTimer_timeout():
	# $CollisionShape2D.set_deferred("disabled", false)
	connect('body_entered', self, '_on_Bullet_body_entered')


func _on_Bullet_body_exited(body):
	if body == thruster:
		connect('body_entered', self, '_on_Bullet_body_entered')

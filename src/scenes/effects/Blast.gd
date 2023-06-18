class_name Blast
extends Area2D

export var blast_damage: float = 20

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	rotation_degrees = randi() % 360
	for b in get_overlapping_bodies():
		if b.is_in_group('on_taking_damage'):
			b.on_taking_damage(blast_damage)
	set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()

class_name Blast
extends Area2D

export var blast_damage_per_second: float = 100



# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_degrees = randi() % 360
	

func _physics_process(delta):
	for b in get_overlapping_bodies():
		if b.has_method('on_taking_damage'):
			b.on_taking_damage(blast_damage_per_second * delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()

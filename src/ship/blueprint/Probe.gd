class_name BPProbe
extends RayCast2D

onready var sprite: Sprite = get_node("sprite")

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	var texture_size: Vector2 = sprite.texture.get_size()
	var caster_scale:float =  cast_to.length() / max(texture_size.x, texture_size.y) 
	sprite.position = Vector2(0, cast_to.length()*0.5)
	sprite.scale = Vector2(caster_scale, caster_scale)
	position -= cast_to * 0.5

func mark_inactive():
	sprite.self_modulate = Color.red

func mark_active():
	sprite.self_modulate = Color.green

func get_overlapping_bodies() -> Array:
	
	force_raycast_update()
	var last_hit = get_collider()
	var hits: Array = []
	while last_hit != null:
		if last_hit:
			add_exception(last_hit)
			if last_hit is Node2D:
				hits.append(last_hit)
	
			force_raycast_update()
			last_hit = get_collider()
	clear_exceptions()
	return hits

class_name BPProbe
extends Area2D

onready var sprite: Sprite = get_node("sprite")
onready var area: CollisionShape2D = get_node("shape")

func _ready():
	var collision_scale:float = area.shape.radius
	sprite.scale = Vector2(collision_scale, collision_scale)

func mark_inactive():
	sprite.modulate = Color.red

func mark_active():
	sprite.modulate = Color.green

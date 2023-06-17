tool
extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var eyeTexture: Texture;
var collision: CollisionObject2D;


# Called when the node enters the scene tree for the first time.
func _ready():
	$EyeSprite.set_texture(eyeTexture)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

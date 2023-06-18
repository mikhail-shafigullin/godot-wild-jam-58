tool
extends EnemyBase

export var eyeTexture: Texture;
onready var eyeSprite = $EyeSprite;
onready var eye_script: ShaderMaterial = eyeSprite.material;
onready var hitTimer: Timer = $HitTimer;


# Called when the node enters the scene tree for the first time.
func _ready():
	$EyeSprite.set_texture(eyeTexture)
	is_boss = true;
	pass # Replace with function body.


func die():
	set_visible(false);
	collision_mask = 0;
	collision_layer = 0;
	
	
func on_taking_damage(damage: float):
	.on_taking_damage(damage)
	print("damage: " + str(damage));
	print("health: " + str(health));
	eye_script.set("shader_param/active", true);
	hitTimer.start();
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HitTimer_timeout():
	eye_script.set("shader_param/active", false);
	pass # Replace with function body.

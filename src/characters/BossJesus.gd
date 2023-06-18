extends EnemyBase

onready var bossSprite = $BossJesus;
onready var boss_script: ShaderMaterial = bossSprite.material;
onready var hitTimer: Timer = $HitTimer;
const EndGameScreen = preload("res://src/scenes/screens/EndGameScreen.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	is_boss = true;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func die():
	State.sceneManager.transition(EndGameScreen)
	pass;


func on_taking_damage(damage: float):
	.on_taking_damage(damage)
	boss_script.set("shader_param/active", true);
	hitTimer.start();
	pass;


func _on_HitTimer_timeout():
	boss_script.set("shader_param/active", false);
	pass # Replace with function body.

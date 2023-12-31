extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speed: float = 500;


# Called when the node enters the scene tree for the first time.
func _ready():
	if State.soundManager :
		State.soundManager.startLevel(global_position.y)
		State.soundManager.setMusicByYCoord(global_position.y)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State.soundManager :
		State.soundManager.setMusicByYCoord(global_position.y)
	
func _physics_process(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed
	translate(velocity * delta)




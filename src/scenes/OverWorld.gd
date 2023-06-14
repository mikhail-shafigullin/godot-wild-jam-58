extends Node2D

export var wind_direction: Vector2 = Vector2.ZERO
export var gravity_direction: Vector2 = Vector2(0, -98)
export var wind_rate: float = 5.0
var uv_offset: Vector3 = Vector3()

onready var world_mask: Node2D = $GameScreen/ViewportControlMask/WorldMask/MaskLayer/Mask
onready var rain_sprite: Sprite = $Camera/Rain
onready var player: Node2D = $"GameScreen/ViewportControlWorld/World/temp world/Player"
onready var bp_manager: Control = $GameScreen/UI/BlueprintManager 
onready var rain_script: ShaderMaterial = rain_sprite.material

func _ready():
	rain_script.set("shader_param/o8625_rainRate", wind_rate)
	rain_script.set("shader_param/o8625_rainSpeed", 1)
	rain_script.set("shader_param/uv1_offset", Vector3(0,0,0))
	world_mask.gravity = gravity_direction
	world_mask.w_offset = wind_direction

	get_tree().connect("screen_resized", self, "_on_resize")
	bp_manager.connect("bp_paused", self, "_on_pause")
	_on_resize()

var mem_wind: Vector2
var mem_gr: Vector2

func _on_pause():
	if get_tree().paused: 
		mem_wind = wind_direction
		wind_direction = Vector2.ZERO
		gravity_direction = Vector2.ZERO
		set_process(false)
	else:
		wind_direction = mem_wind
		gravity_direction = mem_gr
		set_process(true)

func _on_resize():
	rain_sprite.scale = get_viewport().get_size() / rain_sprite.texture.get_size() * 3
	
func _process(delta):
	var w_offset: Vector2 = ( wind_direction + gravity_direction - (player.linear_velocity * Vector2(1,-1)*0.4))
	var w_speed = w_offset.length()
	var ang = w_offset.angle()
	rain_sprite.rotation = -ang - PI*0.5
	uv_offset += Vector3(0, w_speed * world_mask.uv_to_vp.y * delta * 1.5, 0)
	rain_script.set("shader_param/uv1_offset", -uv_offset)
	rain_script.set("shader_param/o8625_rainSpeed", w_speed * 0.2)
	rain_script.set("shader_param/o8625_rainRate", wind_rate)

	world_mask.w_offset = w_offset


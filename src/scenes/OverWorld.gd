class_name OverWorld
extends Node2D
signal player_leave_base

export var wind_direction: Vector2 = Vector2.ZERO
export var gravity_direction: Vector2 = Vector2(0, -98)
export var rain_rate: float = 50.0
var uv_offset: Vector3 = Vector3()

onready var world_mask: Node2D = $GameScreen/ViewportControlMask/WorldMask/MaskLayer/Mask
onready var rain_sprite: Sprite = $"Camera/Rain"
var player: Node2D
onready var bp_manager: Control = $GameScreen/UILayer/UI/BlueprintManager 
onready var rain_script: ShaderMaterial = rain_sprite.material
export var shader_uv_scale: Vector3 = Vector3.ONE
export var player_Z_kill: float = 450

const game_over_popup_face: Resource = preload("res://src/interface/pop_faces/PUFGameOver.tscn")

var money_spend: float = 0
var max_hight: float = 0
var score: float = 0
var player_out: bool = false

var wind: Vector2

func game_over():
	State.ui.get_node("UI/DeathRect").show()
	if get_tree().paused:
		_on_pause()
	State.ui.show_popup(game_over_popup_face.instance(), {	"title": "Game over",
															"max_hight": max_hight,
															"refund": refund_money(),
															"score": score,
															"parts_unlocked": get_unlocked_parts()})

	State.ui.popup.rect_position = State.ui.get_viewport().size * 0.5 - State.ui.popup.rect_size * 0.5
	State.ui.popup.connect("visibility_changed", self, "_global_game_over")

func _global_game_over():
	State.game_over()

func refund_money() -> float:
	if !player_out:
		return money_spend
	print(abs(max_hight))
	return max(abs(max_hight) / 150 + score + (money_spend * (max_hight / 6500)), 500)

var unlocked = []
func get_unlocked_parts():
	for key in State.unlocks:
		if !State.unlocked_parts.has(State.unlocks[key]):
			if max_hight > abs(key):
				unlocked.push_back(State.unlocks[key])
	return unlocked

func get_wind():
	return wind

func get_rain_rate():
	return rain_rate * 1

func _ready():
	get_tree().paused = false
	_on_unpause()
	player = State.player
	State.world = self
	rain_script.set("shader_param/rainRate", rain_rate)
	rain_script.set("shader_param/rainSpeed", 1)
	rain_script.set("shader_param/uv1_offset", Vector3(0,0,0))
	world_mask.gravity = gravity_direction
	world_mask.w_offset = wind_direction

	get_tree().connect("screen_resized", self, "_on_resize")
	bp_manager.connect("bp_paused", self, "_on_pause")
	bp_manager.connect("bp_unpause", self, "_on_unpause")
	_on_resize()

	connect("player_leave_base", State.bp_manager, "free_active_part")

	

var mem_wind: Vector2
var mem_gr: Vector2

func _on_pause():
	mem_wind = wind_direction
	mem_gr = gravity_direction
	wind_direction = Vector2.ZERO
	gravity_direction = Vector2.ZERO
	rain_script.set("shader_param/rainSpeed", 0)
	#rain_sprite.rotation = deg2rad(180)
	set_process(false)
	set_physics_process(false)

func _on_unpause():	
	if mem_gr != Vector2.ZERO:
		wind_direction = mem_wind
		gravity_direction = mem_gr
	set_process(true)
	set_physics_process(true)

func _on_resize():
	var vp_size = get_viewport().get_size()
	rain_sprite.scale = Vector2.ONE * vp_size.y * 2.5
	rain_script.set("shader_param/uv1_scale", shader_uv_scale * 2.5)
	
export var rain_fps: int = 60
export var rain_speed_fps: int = 2
onready var rain_frame_time: float = 1/ float(rain_fps)
onready var rain_speed_frame_time: float = 1/ float(rain_speed_fps)

var rain_time_past: float
var rain_speed_time_past: float


func _process(delta):
	rain_time_past += delta
	rain_speed_fps += delta
	
	var player_vel2: Vector2 = player.linear_velocity*Vector2(1,-1)
	var player_vel3: Vector3 = Vector3(player_vel2.x, -player_vel2.y, 0)
	var w_offset: Vector2 = ( wind_direction + gravity_direction)
	wind = w_offset + Vector2.ONE * player.linear_velocity

	if (rain_time_past >= rain_frame_time):
		uv_offset += (Vector3(w_offset.x, w_offset.y, 0) + player_vel3) * rain_time_past * 0.004 * shader_uv_scale.y
		rain_time_past = 0.0
	
	if (rain_speed_fps >= rain_speed_frame_time):
		var w_speed = (w_offset - player_vel2).length()
		# var ang = (w_offset - player_vel2).angle()
		# rain_sprite.rotation = ang - PI*1.5
		rain_script.set("shader_param/uv1_offset", uv_offset)
		rain_script.set("shader_param/rainSpeed", w_speed * 0.01)
		# rain_script.set("shader_param/rainRate", rain_rate)
		rain_speed_time_past = 0.0


	world_mask.w_offset = w_offset - player_vel2


var o_last_time
func _physics_process(_delta):
	var pyp = -player.global_position.y
	if pyp > max_hight:
		max_hight = pyp
	
	if -pyp > player_Z_kill:
		State.bp_manager.pause_game()
		game_over()
		player.global_position = Vector2.ZERO
	
	var timer: Timer = State.player.get_node("SpawnerTimer")
	
	if (pyp < 800):
		timer.paused = true
	else:
		timer.paused = false
			# if pyp < 3000:
			# 	timer.wait_time = 9
			# 	last_time = 9
			# elif pyp < 6000:
			# 	timer.wait_time = 5
			# 	last_time = 5
			# elif pyp < 9000:
			# 	timer.wait_time = 2
			# 	last_time = 2
			# elif pyp < 13000:
			# 	timer.wait_time = 1
			# 	last_time = 1
			# elif pyp < 16000:
			# 	timer.wait_time = 13
			# 	last_time = 13
			# else:
			# 	timer.paused = true
			# 	last_time = 5555


func player_out():
	emit_signal("player_leave_base")
	player_out = true
	State.ui.shop.hide_node()
	# State.ui.restart_button.hide()

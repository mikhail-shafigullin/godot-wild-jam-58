extends Node2D

var timer;
export var update_rate:float = 0.1
export var rain_half_width: float = 1500.0
export var rain_hight: float = 1000
export var rain_base_rate: float = 50
export var horizontal_easing_dist: float = 50
export var vertical_easing_dist: float = 100 

func _ready():
	timer = Timer.new()
	timer.wait_time = update_rate
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", self , "update_rain")

func update_rain():
	if State.player:
		var ppos = State.player.global_position
		var rate: float = get_rain_rate(ppos) 
		State.world.rain_script.set("shader_param/rainRate", rate)
		State.world.rain_rate = int(rate) 

func get_rain_rate(pos: Vector2) -> float:
	var distance = pos.abs() - global_position.abs()
	var end_pos = Vector2(rain_half_width, rain_hight)

	var rate = rain_base_rate * ( (end_pos - distance) / end_pos )

	# print(rate)
	if pos.abs().y > rain_hight:
		return min(max(rate.x, 0), max(rate.y, 0))
	else:
		return max(rate.x, 0)
		

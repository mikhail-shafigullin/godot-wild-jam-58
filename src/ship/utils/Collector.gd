extends PartUtil

var efficiency: float
export var base_efficiency: float = 1.0

onready var ray_l = $RayLeft
onready var ray_m = $RayMiddle
onready var ray_r = $RayRight
onready var rays = [ray_l, ray_m, ray_r]

onready var anim_sprite = $AnimatedSprite

func _ready():
	anim_sprite.playing = false
	for ray in rays:
		ray.collision_mask = 0
		# ray.set_collision_mask_bit(8, true)
		ray.set_collision_mask_bit(4, true)

func get_efficiency() -> float:
	var not_collided: int = rays.size()
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			not_collided -= 1
	return float(not_collided) / rays.size()

func collect(wind: Vector2) -> float:
	var wind_speed = wind.length() * 0.01
	var v = Vector2.UP.rotated( deg2rad(get_part_global_rotation()) ).dot(wind.normalized())
	return max(efficiency * wind_speed * ((v + 0.5)*0.5), 0)

func on_part_connect():
	anim_sprite.playing = true
	efficiency = base_efficiency * get_efficiency()
	core.collectors.push_back(self)
	set_process(true)

func on_part_disconnect():
	anim_sprite.playing = false
	set_process(false)
	var index = core.collectors.find(self)
	if index != -1:
		core.collectors.remove(index)

func update_efficiency():
	efficiency = base_efficiency * get_efficiency()

export var update_rate: float = 1.0
var time_past: float = 0.0
func _process(delta):
	time_past += delta
	if time_past > update_rate:
		if part_is_connected:
			update_efficiency()
			# print("new efficiency %s"%efficiency)
		time_past = 0.0


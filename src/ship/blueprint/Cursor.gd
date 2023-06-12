extends Panel

const sb_active = preload("res://src/ship/blueprint/cursor_active_sbox.tres")
const sb_normal = preload("res://src/ship/blueprint/cursor_normal_sbox.tres")

export var interpolation_speed: float = 1
export var cursor_size: float = 10
onready var tween = $"Tween"
var follow: bool = true

func _ready():
	mark_normal()
	# focus_on(Vector2(150,100), Vector2(150, 150))

func _process(delta):
	if follow:
		rect_global_position = get_global_mouse_position() - rect_size/2

func focus_on(global_position: Vector2, size: Vector2):
	follow = false
	var center_position = global_position - size/2
	tween.interpolate_property(self, "rect_global_position",
		rect_global_position, global_position, interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	tween.interpolate_property(self, "rect_pivot_offset",
		rect_pivot_offset, size*0.5, interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	tween.interpolate_property(self, "rect_size",
		rect_size, size, interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	tween.start()

func mark_active():
	add_stylebox_override("panel", sb_active)
	follow = false

func mark_normal():
	tween.interpolate_property(self, "rect_size",
		rect_size, cursor_size, interpolation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	add_stylebox_override("panel", sb_normal)
	follow = true

extends Node2D

export var target_vp_path : NodePath
export var w_offset: Vector2 = Vector2.ZERO
export var gravity: Vector2 = Vector2(0, -98)
export var update_length: float = 0.33
export var update_fps: float = 60
export var update_on_every_frame: bool = false

onready var sprite_count: int = update_length * update_fps

var uv_to_vp: Vector2 = Vector2(1,1)
onready var update_time = (1/update_fps)
var time_past: float

onready var vp: Viewport = get_viewport()
var tg_vp: Viewport
var tg_to_vp: Vector2

var sprites: Array = []
var sprite_index: int = 0
var sprite_a_step: float = 0

func _resize():
	uv_to_vp = Vector2( 1, 1 ) / vp.get_size()
	tg_to_vp = vp.get_size() / tg_vp.get_size()
	for s in sprites:
		s.scale = tg_to_vp


func _ready():
	set_process(false)
	set_process_input(false)
	if target_vp_path:
		get_tree().connect("screen_resized", self, "_resize")
		tg_vp = get_node(target_vp_path)
		if tg_vp:
			_resize()
			spawn_sprites()
			set_process(true)

func _process(delta):
	time_past += delta
	if time_past > update_time or update_on_every_frame:
		sprite_index = (sprite_index + 1) % sprite_count
		var sprite: Sprite = sprites[sprite_index]
		sprite.modulate.a = 1
		sprite.texture.create_from_image(tg_vp.get_texture().get_data())
		sprite.set_position( Vector2.ZERO )
		
		
		for s in sprites:
			s.modulate.a -= sprite_a_step
			s.set_position( s.position + (w_offset)*time_past )

		time_past = 0 

func create_sprite() -> Sprite:
	var _sprite
	_sprite = Sprite.new()
	# _sprite.offset = tg_vp.get_size()*0.5
	_sprite.scale = tg_to_vp
	_sprite.set_position( Vector2(9001,9001) )
	_sprite.texture = ImageTexture.new()
	add_child(_sprite)
	return _sprite

func spawn_sprites():
	tg_to_vp = vp.get_size() / tg_vp.get_size()
	sprite_a_step = 1 / float(sprite_count)
	for _i in range(sprite_count):
		sprites.append(create_sprite())

extends Panel

var item_name: String = name
var item_texture: Texture
var item_path: String

onready var icon = $VBoxContainer/Icon

func _ready():
	update_visual()

func update_visual():
	if item_texture:
		icon.texture = item_texture

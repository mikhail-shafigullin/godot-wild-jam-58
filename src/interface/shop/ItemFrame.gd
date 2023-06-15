extends Panel

var item_name: String = name
var item_texture: Texture
var item_path: String

const popup_face = preload("res://src/interface/pop_faces/PUFItemDescription.tscn")

onready var icon = $VBoxContainer/Icon

func _ready():
	update_visual()

func update_visual():
	if item_texture:
		icon.texture = item_texture



func _on_BtnInfo_pressed():
	State.ui.show_popup(popup_face.instance(), {"title": "test", "part_name": item_name})

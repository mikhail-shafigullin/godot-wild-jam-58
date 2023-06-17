extends Panel

var item_name: String = name
var item_texture: Texture
var item_path: String

const popup_face: Resource = preload("res://src/interface/pop_faces/PUFItemDescription.tscn")
const lock_texture: Texture = preload("res://src/ship/blueprint/pin_target.png")


onready var icon = $VBoxContainer/Icon

func _ready():
	update_visual()

func lock():
	$LockRect.show()
	$BtnInfo.hide()
	$VBoxContainer/HBoxContainer/BtnBuy.hide()
	icon.texture = lock_texture

func update_visual():
	if State.unlocked_parts.has(item_name):
		if item_texture:
			icon.texture = item_texture
	else:
		lock()

func _on_BtnInfo_pressed():
	State.ui.show_popup(popup_face.instance(), {"title": "%s"%item_name})

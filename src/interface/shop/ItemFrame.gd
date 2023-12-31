extends Panel

var item_name: String = name
var item_texture: Texture
var item_path: String
var item_price: float
var item_data: Dictionary = {}

onready var buy_button = $VBoxContainer/HBoxContainer/BtnBuy

const popup_face: Resource = preload("res://src/interface/pop_faces/PopUpFace.tscn")
const lock_texture: Texture = preload("res://src/ship/blueprint/pin_target.png")


onready var icon = $VBoxContainer/Icon

func _ready():
	update_visual()

func _gui_input(event):
	update_frame()

func lock():
	$LockRect.show()
	buy_button.hide()
	$BtnInfo.hide()
	icon.texture = lock_texture

func update_visual():
	item_data["title"] = "%s"%item_name
	if State.unlocked_parts.has(item_name):
		if item_texture:
			icon.texture = item_texture
		if item_price:
			$VBoxContainer/HBoxContainer/BtnBuy.text = "buy: %s"%item_price
		update_frame()
	else:
		lock()

func _on_BtnInfo_pressed():
	State.ui.show_popup(popup_face.instance(), item_data)

func _on_BtnBuy_pressed():
	buy_part()

func buy_part():
	if update_frame():
		State.world.money_spend += item_price
		State.bp_manager.buy_part(item_path, item_price)
		update_visual()

func update_frame() -> bool:
	if State.scrap <= item_price:
		buy_button.disabled = true
		return false
	else: 
		buy_button.disabled = false
		return true
	

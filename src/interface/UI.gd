extends CanvasLayer

onready var popup: WindowDialog = $"UI/PopUp"
onready var shop: Panel = $UI/Shop
onready var bp_manager: BlueprintManager = $UI/BlueprintManager
onready var binder_dialog: ConfirmationDialog = $UI/ActionBindDialog
onready var fuel_gauge: TextureProgress = $UI/Fuel
onready var restart_button: Button = $UI/Button

var zoom: Vector2 = Vector2.ONE
var zoom_step: Vector2 = Vector2.ONE * 0.1

var popup_size: Vector2
func _ready():
	State.ui = self


func _physics_process(_delta):
	fuel_gauge.value = State.player.resource / State.player.resource_max

func show_popup(popup_face: PopUpFace, data: Dictionary):
	if popup.get_children():
		for c in popup.get_children():
			if c is PopUpFace:
				c.queue_free()
	popup_face.set_data(data)
	popup.add_child(popup_face)
	popup.popup_centered_minsize(popup_face.rect_min_size)
	
	var p_size = popup.get_rect().size
	var c_pos = get_viewport().get_mouse_position()
	var vp_size = get_viewport().size
	var new_pos = c_pos
	if (new_pos.x + p_size.x > vp_size.x):
		new_pos.x -= p_size.x
	if (new_pos.y + p_size.y > vp_size.y):
		new_pos.y -= vp_size.y	

	popup.set_position(new_pos)

	
	popup.window_title = popup_face.title


func _on_Button_pressed():
	State.world.game_over()

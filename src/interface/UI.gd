extends CanvasLayer

onready var popup: WindowDialog = $"UI/PopUp"
onready var shop: Panel = $UI/Shop
onready var bp_manager: BlueprintManager = $UI/BlueprintManager
onready var binder_dialog: ConfirmationDialog = $UI/ActionBindDialog
onready var fuel_gauge: TextureProgress = $UI/Fuel
onready var restart_button: Button = $UI/Button
onready var heightLabel: RichTextLabel = $UI/HeightLabel

var zoom: Vector2 = Vector2.ONE
var zoom_step: Vector2 = Vector2.ONE * 0.25

var popup_size: Vector2
func _ready():
	State.ui = self
	State.player.camera.zoom = State.ui.zoom
	
func _process(delta):
	set_height();

func zoom_in():
	_zoom(true)

func zoom_out():
	_zoom(false)

func _zoom(zoom_out: bool):
	if zoom_out:
		if State.ui.zoom > Vector2(0.33,0.33):
			State.ui.zoom -= State.ui.zoom_step
			State.world.rain_script.set("shader_param/uv1_scale", State.world.shader_uv_scale * 2.5 * State.ui.zoom.y)
	else: 
		if State.ui.zoom < Vector2(2,2):
			State.ui.zoom += State.ui.zoom_step
			State.world.rain_script.set("shader_param/uv1_scale", State.world.shader_uv_scale * 2.5 * State.ui.zoom.y)
	State.player.camera.zoom = State.ui.zoom

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

func set_height():
	if State.player : 
		var height = 35 + floor(State.player.global_position.y);
		heightLabel.set_text(str(abs(height)))

func _on_Button_pressed():
	State.world.game_over()

extends Button

var scancode: int;

func _pressed():
	var binder = State.ui.binder_dialog
	binder.popup_centered_minsize(Vector2(10,10))
	binder.connect("visibility_changed", self, "_get_action")

func _get_action():
	var binder = State.ui.binder_dialog
	binder.disconnect("visibility_changed", self, "_get_action")
	if (binder.hotkey):
		scancode = binder.hotkey.scancode
	if (scancode):
		text = OS.get_scancode_string(scancode)

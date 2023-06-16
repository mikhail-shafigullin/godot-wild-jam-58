extends ConfirmationDialog
signal closed

var hotkey: InputEventKey = null
var active: bool = false

func _ready():
	connect("about_to_show", self, "_setup")

func _setup():
	hotkey = null
	
	if (randf() < 0.08):
		dialog_text = "< ok, throw me some numbers >"
	else:
		dialog_text = "< press any key >"
	

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_ESCAPE:
				hotkey = null
				dialog_text = " < null > "
				hide()
				return

			hotkey = event
			dialog_text =      "  >          [%s]         <   "%OS.get_scancode_string(event.scancode)

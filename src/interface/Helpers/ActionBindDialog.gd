extends ConfirmationDialog

var hotkey: InputEventKey = null

func _ready():
    connect("about_to_show", self, "_setup")

func _setup():
    hotkey = null
    if (randf() < 0.08):
        dialog_text = "< throw me some numbers >"
    else:
        dialog_text = "< press any key >"

func _unhandled_key_input(event: InputEventKey):
    if event.pressed:
        if event.scancode == KEY_ESCAPE:
            hide()
            return

        hotkey = event
        dialog_text =      "  >          [%s]         <   "%OS.get_scancode_string(event.scancode)



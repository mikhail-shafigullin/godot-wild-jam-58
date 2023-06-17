extends HBoxContainer

var functions: Array = []
var scancode: int = -1

func update_code():
    if scancode != -1:
        $BindButton.scancode = scancode
        $BindButton.text = OS.get_scancode_string(scancode)
        $CallLable.text = String(functions)

func scan():
    if $BindButton.scancode != -1:
        scancode = $BindButton.scancode
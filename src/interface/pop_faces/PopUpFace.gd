class_name PopUpFace
extends Control

var title:String = "popup"
var part_name: String = "none"

func set_data(data: Dictionary):
    if data.has("part_name"):
         if data.has("title"):
            title = "%s: %s"%[data.get("title"), data.get("part_name")]
         else:
            title = data.get("part_name")
    

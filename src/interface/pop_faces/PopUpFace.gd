class_name PopUpFace
extends Control

var title:String = "popup"
var part_name: String = "none"

func set_data(data: Dictionary):
   if data.has("title"):
      title = data["title"]
   
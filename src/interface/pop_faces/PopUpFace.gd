class_name PopUpFace
extends Control

var title:String = "popup"
var part_name: String = "none"

var data: Dictionary = {}

func set_data(_data: Dictionary):
   data = _data
   for key in data.keys():
      set(key, data[key])
   
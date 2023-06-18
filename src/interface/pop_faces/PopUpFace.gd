class_name PopUpFace
extends VBoxContainer

var title:String = "popup"
var part_name: String = "none"

var data: Dictionary = {}
var lbls = self

func set_data(_data: Dictionary):
   data = _data
   for key in data.keys():
      set(key, data[key])
      if lbls:
         var lb = Label.new()
         lb.align = ALIGN_CENTER
         lbls.add_child(lb)
         lb.text = "%s: %s"%[key,String(data[key])]
      
   
   
   
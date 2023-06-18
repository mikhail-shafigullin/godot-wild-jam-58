extends PopUpFace


onready var labels = $VBoxContainer

func _init():
    lbls = null

func _ready():
    for label in labels.get_children():
        for key in data.keys():
            print(key)
            if labels.has_node(key):
                var node = labels.get_node(key)
                node.set("text", "%s : %s"%[key ,data[key]])

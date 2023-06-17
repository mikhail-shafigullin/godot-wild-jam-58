extends PopUpFace

onready var labels = $Lables

func _ready():
    for label in labels.get_children():
        for key in data.keys():
            print(key)
            var node = labels.get_node(key)
            if node:
                node.set("text", "%s : %s"%[key ,data[key]])

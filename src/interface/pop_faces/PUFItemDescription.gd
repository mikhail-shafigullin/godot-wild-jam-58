extends PopUpFace

func _ready():
	for label in lbls.get_children():
		for key in data.keys():
			print(key)
			var node = lbls.get_node(key)
			if node:
				node.set("text", "%s : %s"%[key ,data[key]])
	lbls = $Lables

extends Panel

const structs_path: String = 'res://src/ship/struct/'
const thrust_path: String = "res://src/ship/thrust/"
const collect_path: String = "res://src/ship/collect/"
const util_path: String = "res://src/ship/utils/"

onready var struct_grid = $ShopHB/Container/Struct/GridContainer/StructGrid
onready var thrust_grid = $ShopHB/Container/Thrust/GridContainer/TrustGrid
onready var collect_grid = $ShopHB/Container/Collect/GridContainer/CollectGrid
onready var util_grid = $ShopHB/Container/Util/GridContainer/UtilGrid

onready var item_frame = preload("res://src/interface/shop/ItemFrame.tscn")

func _ready():
	populate_shop()

func populate_shop():
	
	_populate_grid(struct_grid, structs_path)
	_populate_grid(thrust_grid, thrust_path)
	_populate_grid(collect_grid, collect_path)
	_populate_grid(util_grid, util_path)
	pass


func _populate_grid(grid: GridContainer, items_path: String):
	for c in grid.get_children():
		c.queue_free()

	for f in get_files(items_path):
		print(f)
		var r: PackedScene = load(items_path + f)
		var r_n = r.instance()
		print( r_n)
		if r_n is PartBase:
			print("yes")
			var frame = item_frame.instance()
			frame.item_name = f.split(".")[0]
			#print("part name: %s"%f.split(".")[0])
			frame.item_texture = r_n.item_icon
			grid.add_child(frame)

		r_n.queue_free()

func get_files(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			if file.ends_with(".tscn"):
				files.append(file)

	dir.list_dir_end()

	return files


func _on_ShowButton_toggled(button_pressed:bool):
	if button_pressed:
		$AnimationPlayer.play("hide")
	else:
		$AnimationPlayer.play("show")

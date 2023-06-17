extends PopUpFace
# [ { ActionType.CALL : [0 keycode, 1 [func_name(s)] }, ... ]

# [ { ActionType.SET  : [0   var  , 1  value   ] }, ... ]

const call_bind = preload("res://src/interface/Helpers/CallPromt.tscn")
const var_bind = preload("res://src/interface/Helpers/VarPromt.tscn")
onready var vbox = $VBoxContainer

var call_binders: Array = []
var var_binders: Array = []

func setup_for(controller :ActionController):
	for dictionary in controller.data:
		if dictionary.has(ActionController.ActionType.CALL):
			create_call_prompt(dictionary.get(ActionController.ActionType.CALL))
		if dictionary.has(ActionController.ActionType.SET):
			create_var_prompt(dictionary.get(ActionController.ActionType.SET))

func get_controller() -> ActionController:
   var ctrl = ActionController.new()
   for binder in call_binders:
      binder.scan()
      if binder.functions.size() == 2: 
         ctrl.bind_action(binder.scancode, binder.functions[0], binder.functions[1])
      else:
         ctrl.bind_action(binder.scancode, binder.functions[0])
   for binder in var_binders: pass;
   return ctrl


func create_call_prompt(data: Array):
   var binder = call_bind.instance()
   vbox.add_child(binder)
   binder.functions = data[1]
   binder.scancode = data[0]
   binder.update_code()
   call_binders.push_back(binder)

func create_var_prompt(data: Array):
   var binder = var_bind.instance()
   vbox.add_child(binder)
   binder.functions = data[1]
   binder.scancode = data[0]
   var_binders.push_back(binder)


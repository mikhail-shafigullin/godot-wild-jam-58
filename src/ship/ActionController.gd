class_name ActionController
extends Object


# [ { ActionType.CALL : [0 keycode, 1 [func_name(s)] }, ... ]
    # [0 function = on_press, # 1 (optional) function = on_release]

# [ { ActionType.SET  : [0   var  , 1  value   ] }, ... ]
enum ActionType { CALL, SET}
var data: Array = [] 

func bind_action(scancode: int, function_press: String, function_release = null):
    var functions: Array = [function_press]
    if function_release: functions.append(function_release);

    self.data.append_array( [{ ActionType.CALL :
                                    [scancode, functions] }])


extends Node
var ButtonName

func _ready():
	ButtonName = self.get_name()
	print(ButtonName + " ready!")
	pass

func _on_testBtn_pressed():
	print(ButtonName + " pressed!")
	get_node("/root/main").mainFunc(-1, true, false)
	pass # replace with function body

func _on_logBtn_pressed():
	print(ButtonName + " pressed!")
	get_node("/root/main").mainFunc(0, false, "")
	pass # replace with function body

func _on_addLine_pressed():
	print(ButtonName + " pressed!")
	get_node("/root/main").mainFunc(1, true, false)
	pass # replace with function body

func _on_addCategory_pressed():
	print(ButtonName + " pressed!")
	get_node("/root/main").mainFunc(2, true, false)
	pass # replace with function body


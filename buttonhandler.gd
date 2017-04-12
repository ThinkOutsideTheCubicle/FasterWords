extends Node
var ButtonName
var mainNode

func _ready():
	ButtonName = self.get_name()
	mainNode = get_node("/root/main")
	
	print(ButtonName + " ready!")
	pass

func _on_logBtn_pressed():
	mainNode.writeLog(ButtonName + " pressed!")
	mainNode.mainFunc(0, false, "")
	pass

func _on_addCategory_pressed():
	mainNode.writeLog(ButtonName + " pressed!")
	mainNode.mainFunc(3, true, false)
	pass

func _on_langBtn_item_selected(ID):
	mainNode.writeLog("id " + str(ID) + " selected")
	mainNode.setLanguage(ID)
	mainNode.setupCategorys(true, null)
	pass

func _on_OKBtn_pressed():
	mainNode.writeLog(ButtonName + " pressed!")
	# mainNode.mainFunc(-1, true, false)
	self.get_parent().hide()
	pass

func _on_catOptionBtn_pressed():
	mainNode.writeLog(ButtonName + " pressed!")
	mainNode.mainFunc(2, true, 1)
	pass

#### TODO-Buttons:
func _on_changelogBtn_pressed():
	mainNode.writeLog(ButtonName + " pressed!")
	mainNode.mainFunc(2, true, 0)
	pass

func _on_addLine_pressed():
	mainNode.writeLog(ButtonName + " pressed!")
	mainNode.mainFunc(1, true, false)
	pass

func _on_testBtn_pressed():
	mainNode.writeLog(ButtonName + " pressed!")
	mainNode.mainFunc(-1, true, false)
	pass

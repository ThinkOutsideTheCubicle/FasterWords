extends Node

var myVersion = {
	name		= Globals.get("application/name"),
	major		= 0, 
	minor		= 0,
	patch		= 1,
	status		= "pre-alpha",
	revision	= "unstable"
}

var shownPopups = []
var a2zArray = []

# each category -> name | hidden | deletable | shown-id (from left to right, 0 is first) --> ["Stadt", true, false, 0]
var categorys = [["Stadt", true, false, 0], ["Land", false, false, 1], ["Fluss", false, false, 2]]
var showncategorys = []

var treeNode
var treeRoot
var treeItems = []

var catTreeNode
var catTreeRoot
var catTreeItems = []

var mainRect
var resizing = false
var currentLog = ""
var logEnabled = true
var icons = [load("res://tex/del.png"), load("res://tex/off.png"), load("res://tex/on.png")]

func toggleLog():
	
	var newSize = treeNode.get_size()
	var logWitdh = get_node("logPanel").get_size().width
	
	var logMsg = "Log is now "
	
	if (logEnabled == true):
		newSize.width += logWitdh
		logMsg += "hidden."
		logEnabled = false
	elif (logEnabled == false):
		newSize.width -= logWitdh
		logMsg += "shown."
		logEnabled = true
	
	treeNode.set_size(newSize)
	writeLog(logMsg)
	# treeNode.grab_focus()
	pass

func writeLog(message):
	var logNode = get_node("logPanel/log")
	
	logNode.newline()
	logNode.add_text("> " + str(message))
	logNode.newline()
	
	currentLog += "\n" + str(message)
	
	# logNode.add_text(message)
	# logNode.newline()
	
	# logNode.set_text(currentLog)
	# logNode.cursor_set_line(logNode.get_line_count())
	# logNode.select_all()
	pass

func init():
	# get_node("log").set_readonly(true)
	
	treeNode = get_node("Tree")
	catTreeNode = get_node("WindowDialog/Tree1")
	
	get_node("logPanel/log").set_scroll_follow(true)
	
	myVersion.string = myVersion.name + " v" + str(myVersion.major) + "." + str(myVersion.minor) + "." + str(myVersion.patch) + " " + myVersion.status + " (" + myVersion.revision + ")"
	writeLog(myVersion.string + " using Godot Version " + OS.get_engine_version().values()[2])
	
	for i in range(65, 91):
		a2zArray.append([RawArray([i]).get_string_from_utf8(), false])
	writeLog(str(a2zArray))
	
	setupCategorys(true, null)
	# mainFunc(0, true)
	OS.set_window_title(myVersion.string + " | " + OS.get_name())
	
	mainRect = Rect2(OS.get_window_position(), OS.get_window_size())
	writeLog("mainRect: " + str(mainRect))
	
	shownPopups = [get_node("AcceptDialog").is_visible(), get_node("WindowDialog").is_visible()]
	writeLog("shownPopups: " + str(shownPopups))
	
	toggleLog()
	writeLog("ready!")

func _ready():
	init()
	pass

func setupCategorys(reset, addCategory):
	
	if (reset):
		# treeNode.get_children().clear()
		# catTreeNode.get_children().clear()
		
		treeRoot = treeNode.clear()
		treeRoot = treeNode.create_item()
		treeNode.set_hide_root(true)
		treeNode.set_select_mode(0)
		treeNode.set_hide_folding(true)
		treeNode.set_column_titles_visible(true)
		
		catTreeRoot = catTreeNode.clear()
		catTreeRoot = catTreeNode.create_item()
		catTreeNode.set_hide_root(true)
		catTreeNode.set_select_mode(0)
		catTreeNode.set_hide_folding(true)
		catTreeNode.set_column_titles_visible(true)
		
	# process addCategorys
	if (addCategory != null):
		categorys.append(addCategory)
	
	writeLog("categorys = " + str(categorys) + " | size = " + str(categorys.size()))
	# get_node("Tree").set_columns(categorys.size() + 1)
	
	catTreeNode.set_columns(3)
	catTreeNode.set_column_title(0, "category")
	catTreeNode.set_column_title(1, "hidden")
	catTreeNode.set_column_title(2, "delete")
	
	catTreeNode.set_column_min_width(1, 100)
	catTreeNode.set_column_expand(1, false)
	
	catTreeNode.set_column_min_width(2, 100)
	catTreeNode.set_column_expand(2, false)
	
	# count reset/rebuild all shown category's
	showncategorys.clear()
	catTreeItems.clear()
	
	for i in range(categorys.size()):
		var catItem = categorys[i]
		writeLog("name=" + catItem[0] + " | hidden=" + str(catItem[1]) + " | deletable=" + str(catItem[2]) + " | shown-id=" + str(catItem[3]))
		
		catTreeItems.append(catTreeNode.create_item(catTreeRoot))
		catTreeItems[i].set_text(0, catItem[0])
		catTreeItems[i].set_editable(0, catItem[2])
		
		# catTreeItems[i].set_text(1, str(catItem[1]))
		catTreeItems[i].add_button(1, icons[catItem[1] + 1], i)
		
		# catTreeItems[i].set_text(2, str(catItem[2]))
		catTreeItems[i].add_button(2, icons[0], i, !catItem[2])
		
		if (catItem[1] == false):
			# showncategorys += 1
			showncategorys.append(catItem[0])
		else:writeLog(catItem[0] + " is hidden")
	
	writeLog("showncategorys=" + str(showncategorys.size()) + " | " + str(showncategorys) + " | catTreeItems.size=" + str(catTreeItems.size()))
	treeNode.set_columns(showncategorys.size() + 1)
	treeNode.set_column_title(0, "Buchstabe")
	treeNode.set_column_min_width(0, 100)
	treeNode.set_column_expand(0, false)
	
	for i in range(showncategorys.size()):
		writeLog("processing category " + str(i) + " | " + str(showncategorys[i]))
		treeNode.set_column_title(i + 1, showncategorys[i])
	# get_node("Tree").set_columns(showncategorys.size() + 1)
	pass

func getRandomInt(minimal, maximal):
	randomize()
	var returnVal = randi() % maximal
	return returnVal

func getCenterPos(currentSize):
	var cWinSize = OS.get_window_size()
	var newpos = (cWinSize/2) - (currentSize/2)
	
	# writeLog("currentSize=" + str(currentSize) + " | cWinSize=" + str(cWinSize) + " | newpos=" + str(newpos))
	return newpos

func getNode(id):
	var retNode
	
	if (id == 0):
		retNode = get_node("AcceptDialog")
	elif (id == 1):
		retNode = get_node("WindowDialog")
	return retNode

func setPopupPos(id):
	var selectedNode = getNode(id)
	var newpos = getCenterPos(selectedNode.get_size())
	selectedNode.set_pos(newpos)
	pass

func showPopup(id, message):
	writeLog("shownPopup | id=" + str(id) + " | message=" + message)
	
	var selectedNode = getNode(id)
	setPopupPos(id)
	
	writeLog(message)
	if (id == 0):
		selectedNode.set_text(message)
	selectedNode.show()
	
	shownPopups[id] = selectedNode.is_visible()
	writeLog("showPopup --> shownPopups: " + str(shownPopups) + " | id=" + str(id) + " | selectedNode.is_visible()" + str(selectedNode.is_visible()))
	
	# get_node("Timer").set_wait_time(1)
	# if(get_node("Timer").is_active() == false):
		# get_node("Timer").start()
	pass

func mainFunc(id, printLog, value):
	
	if (printLog):writeLog("id=" + str(id) + " | value=" + str(value))
	
	if (id == -1):
		showPopup(1, "no letters left!")
	elif (id == 0):
		toggleLog()
	elif (id == 1):
		if (value == true):
			writeLog("resetting lines")
			treeItems.clear()
		else:
			writeLog("unsetting old lines for editing")
			for i in range(treeItems.size()):
				for iCat in range(showncategorys.size() + 1):
					treeItems[i].set_editable(iCat, false)
		
		writeLog("getting free letter")
		
		var freeCounter = 0
		for i in range(a2zArray.size() - 1):
			var item = a2zArray[i]
			if (item[1] == false):
				freeCounter += 1
		writeLog("freeCounter=" + str(freeCounter))
		
		if (freeCounter == 0):
			showPopup(0, "no letters left!")
		else:
			var proceed = false
			var randID
			while (proceed == false):
				randID = getRandomInt(0, a2zArray.size())
				
				var item = a2zArray[randID]
				if (item[1] == false):
					a2zArray[randID] = [item[0], true]
					proceed = true
				if (proceed == true):
					break
			
			writeLog("randID=" + str(randID))
			
			writeLog("adding new line")
			treeItems.append(treeNode.create_item(treeRoot))
			
			var lastLineID = treeItems.size() - 1
			writeLog("lastLineID = " + str(lastLineID))
			writeLog("real columns = " + str(treeNode.get_columns()))
			
			for i in range(showncategorys.size() + 1):
				# writeLog("i=" + str(i))
				
				if (i == 0):
					var letter = a2zArray[randID]
					writeLog("letter=" + letter[0])
					treeItems[lastLineID].set_text(0, letter[0])
					treeItems[lastLineID].set_selectable(0, false)
				else:
					treeItems[lastLineID].set_editable(i, true)
	elif (id == 2):
		setupCategorys(true, ["new Category", false, true, categorys.size()])
	else:
		writeLog("THE CAKE IS A LIE!!!")
	pass

func _on_Timer_timeout():
	var timerMsg = "timer is idle"
	var primMsg = false
	resizing = false
	
	var currRect = Rect2(OS.get_window_position(), OS.get_window_size())
	
	if (currRect.size != mainRect.size):
		timerMsg = "currRect=" + str(currRect) + " | currRect=" + str(mainRect)
		resizing = true
		mainRect = currRect
		# mainRect = Rect2(OS.get_window_position(), OS.get_window_size())
	
	if (resizing == true):
		primMsg = true
		
		for i in range(shownPopups.size()):
			if (shownPopups[i] == true):
				timerMsg += "i=" + str(i) + " | " + str(shownPopups[i])
				setPopupPos(i)
	
	if (primMsg == true):writeLog(timerMsg)
	
	pass

func _on_AcceptDialog_confirmed():
	shownPopups[0] = get_node("AcceptDialog").is_visible()
	writeLog("shownPopups: " + str(shownPopups))
	pass

func _on_AcceptDialog_visibility_changed():
	shownPopups[0] = get_node("AcceptDialog").is_visible()
	writeLog("shownPopups: " + str(shownPopups))
	pass

func _on_WindowDialog_visibility_changed():
	shownPopups[1] = get_node("WindowDialog").is_visible()
	writeLog("shownPopups: " + str(shownPopups))
	pass

func _on_Tree1_item_edited():
	for i in range(categorys.size()):
		categorys[i][0] = catTreeItems[i].get_text(0)
	setupCategorys(true, null)
	pass

func _on_Tree1_button_pressed(item, column, id):
	writeLog("item.text=" + str(item.get_text(0)) + " | column=" + str(column) + " | id=" + str(id))
	
	if (column == 1):
		categorys[id][1] = !categorys[id][1]
	elif (column == 2):
		categorys.remove(id)
	
	setupCategorys(true, null)
	
	pass # replace with function body

extends Node
var langNode

var myVersion = {
	name		= Globals.get("application/name"),
	major		= 0, 
	minor		= 0,
	patch		= 3,
	status		= "pre-alpha",
	revision	= "unstable",
	url			= "https://github.com/ThinkOutsideTheCubicle/FastWords/"
}

var settings = {
	path				= "res://settings.cfg",
	autoSave			= false,
	autoLoad			= false,
	language			= [],
	screen				= [],
	fullscreen			= false,
	screenID			= 0,
	logEnabled			= true,
	customCategorys		= []
}

var shownPopups = []
var a2zArray = []

# each category -> title | hidden | deletable | shown-id (from left to right, 0 is first) --> ["Stadt", true, false, 0]
var categorys = [["", false, false, 0], ["", false, false, 1], ["", false, false, 2]]
var showncategorys = []

var treeNode
var treeRoot
var treeItems = []

var catTreeNode
var catTreeRoot
var catTreeItems = []

var resizing = false
var currentLog = ""
var icons = [load("res://tex/del.png"), load("res://tex/off.png"), load("res://tex/on.png")]
var logNode
var logWidth
var currPos

func _ready():
	init()
	pass

func init():
	# setup the log
	logNode = get_node("logPanel/log")
	get_node("logPanel/log").set_scroll_follow(true)
	
	logWidth = get_node("logPanel").get_size().width
	writeLog("logWidth=" + str(logWidth))
	
	# setup nodes
	treeNode = get_node("Tree")
	treeNode.set_size(treeNode.get_size() + Vector2(logWidth, 0))
	
	catTreeNode = get_node("WindowDialog/Tree1")
	
	# setup main strings
	myVersion.license = myVersion.url + "blob/master/LICENSE"
	
	myVersion.string = myVersion.name + " v" + str(myVersion.major) + "." + str(myVersion.minor) + "." + str(myVersion.patch) + " " + myVersion.status + " (" + myVersion.revision + ")"
	writeLog(myVersion.string + " using Godot Version " + OS.get_engine_version().values()[2])
	OS.set_window_title(myVersion.string + " | " + OS.get_name())
	
	# loading languages
	writeLog("loading languages")
	langNode = get_node("/root/lang")
	
	if (langNode.loaded == true):
		writeLog("done")
	
	# setup languages-button
	get_node("langBtn").add_item(langNode.en.language)
	get_node("langBtn").add_item(langNode.de.language)
	
	# loop until languages are loaded .. we maybe need it in later releases
	"""
	var counter = 1
	while(counter != 0):
		counter += 1
		
		# print(strings[i])
		writeLog("langsLoaded=" + str(langsLoaded) + " | counter=" + str(counter))
		
		if (langsLoaded == true):
			counter = 0
			writeLog("done")
		else:
			OS.delay_msec(1000)
	"""
	settings.screenID = OS.get_current_screen()
	writeLog("settings.screenID: " + str(settings.screenID))
	
	settings.fullscreen = OS.is_window_fullscreen()
	
	currPos = OS.get_screen_position(settings.screenID) + OS.get_window_position()
	settings.screen = Rect2(currPos, OS.get_window_size())
	writeLog("settings.screen: " + str(settings.screen))
	
	shownPopups = [get_node("InfoWindow").is_visible(), get_node("WindowDialog").is_visible()]
	writeLog("shownPopups: " + str(shownPopups))
	
	setLanguage(0)
	toggleLog(settings.logEnabled)
	
	# loading settings
	procSettings()
	# toggleLog(settings.logEnabled)
	
	setupCategorys(true, null)
	
	writeLog("ready!")
	pass

func procSettings(loadfile=true):
	# writeLog("settings.path=" + settings.path)
	# langNode.currLang
	# settings.language
	
	# settings.options.append(["language", langNode.currLang.id])
	# settings.options.append(["id", langNode.currLang.language])
	var configFile = ConfigFile.new()
	
	if (loadfile == true):
		var err = configFile.load(settings.path)
		writeLog("configFile.load=" + str(err))
	
		if (err == OK):
			# settings.language = [langNode.currLang.id, langNode.currLang.language]
		
			var currSection = "Settings"
			var readSetting = ""
			
			if (configFile.has_section(currSection) == true):
				readSetting = [configFile.get_value(currSection, "langID", settings.language[0]), configFile.get_value(currSection, "language", settings.language[1])]
				settings.language = readSetting
				
				if (configFile.has_section_key(currSection, "logEnabled") == true):
					readSetting = configFile.get_value(currSection, "logEnabled", settings.logEnabled)
					
					if (settings.logEnabled != readSetting):
						settings.logEnabled = readSetting
						toggleLog(settings.logEnabled)
					# toggleLog(settings.logEnabled)
				
				if (configFile.has_section_key(currSection, "screenID") == true):
					settings.screenID = configFile.get_value(currSection, "screenID", settings.screenID)
				
				if (configFile.has_section_key(currSection, "screen") == true):
					settings.screen = configFile.get_value(currSection, "screen", settings.screen)
				
				if (configFile.has_section_key(currSection, "fullscreen") == true):
					settings.fullscreen = configFile.get_value(currSection, "fullscreen", settings.fullscreen)
				
			currSection = "CustomCategories"
			if (configFile.has_section(currSection) == true):
				var keyValues = configFile.get_section_keys("CustomCategories")
				
				for i in range(keyValues.size()):
					readSetting = configFile.get_value(currSection, str(i))
					setupCategorys(true, [readSetting[0], readSetting[1], readSetting[2], categorys.size()])
	
	writeLog("settings.language=" + str(settings.language))
	setLanguage(settings.language[0])
	
	configFile.set_value("Settings", "langID", settings.language[0])
	configFile.set_value("Settings", "language", settings.language[1])
	
	writeLog("settings.logEnabled=" + str(settings.logEnabled))
	configFile.set_value("Settings", "logEnabled", settings.logEnabled)
	
	writeLog("settings.screenID=" + str(settings.screenID))
	configFile.set_value("Settings", "screenID", settings.screenID)
	OS.set_current_screen(settings.screenID)
	
	writeLog("settings.screen=" + str(settings.screen))
	configFile.set_value("Settings", "screen", settings.screen)
	OS.set_window_position(settings.screen.pos)
	OS.set_window_size(settings.screen.size)
	
	writeLog("settings.fullscreen=" + str(settings.fullscreen))
	configFile.set_value("Settings", "fullscreen", settings.fullscreen)
	OS.set_window_fullscreen(settings.fullscreen)
	
	if (settings.customCategorys.size() > 0):
			for i in range(settings.customCategorys.size()):
				# title | hidden | deletable | shown-id
				configFile.set_value("CustomCategories", str(i), settings.customCategorys[i])
	
	if(settings.autoSave == false):
		configFile.save(settings.path)
	
	# configFile.close()
	
	writeLog(str(settings.keys()))
	pass

func loadTextFile(path):
	var openFile = File.new()
	openFile.open(path, File.READ)
	
	var returnStr = openFile.get_as_text()
	openFile.close()
	
	return returnStr

func setLanguage(langID=0):
	
	langNode.currLang = langNode.getLang(langID)
	settings.language = [langNode.currLang.id, langNode.currLang.language]
	
	get_node("langBtn").clear()
	
	get_node("langBtn").add_item(langNode.en.language)
	get_node("langBtn").add_item(langNode.de.language)
	get_node("langBtn").select(langNode.currLang.id)
	
	writeLog("setting language to " + langNode.currLang.language + " (id " + str(langNode.currLang.id) + ")")
	
	categorys[0][0] = langNode.currLang.stockCat[0]
	categorys[1][0] = langNode.currLang.stockCat[1]
	categorys[2][0] = langNode.currLang.stockCat[2]
	
	var infoStr = "[right][url=" + myVersion.url + "]" + langNode.currLang.mainStrings[0] + "[/url] - [url=" + myVersion.url + "blob/master/LICENSE]" + langNode.currLang.mainStrings[1] + "[/url] - [url=" + myVersion.url + "releases]" + langNode.currLang.mainStrings[2] + "[/url][/right]"
	get_node("infoLabel").set_bbcode(infoStr)
	get_node("MenuPanel/addLine").set_text(langNode.currLang.string1)
	pass

func toggleLog(setTo=-1):
	
	writeLog("setTo=" + str(setTo) + " | settings.logEnabled=" + str(settings.logEnabled))
	var logMsg = "Log is now "
	
	if (setTo != -1):
		if (settings.logEnabled != setTo):
			settings.logEnabled = setTo
	else:
		settings.logEnabled = (!settings.logEnabled)
	
	var newSize = treeNode.get_size()
	
	if (settings.logEnabled == false):
		newSize.width += logWidth
		logMsg += "hidden."
	else:
		newSize.width -= logWidth
		logMsg += "shown."
	
	treeNode.set_size(newSize)
	get_node("logBtn").set_pressed(settings.logEnabled)
	
	writeLog(logMsg + " | " + str(setTo) + " | " + str(settings.logEnabled))
	pass

func writeLog(message, useBB=false):
	var addLine = "\n> "
	
	if (useBB == true):
		logNode.append_bbcode(addLine + str(message))
	else:
		logNode.add_text(addLine + str(message))
	logNode.newline()
	
	currentLog += "\n" + str(message)
	pass

func resetA2Z():
	a2zArray.clear()
	
	for i in range(65, 91):
		a2zArray.append([RawArray([i]).get_string_from_utf8(), false])
	writeLog(str(a2zArray))
	pass

func setupCategorys(reset, addCategory):
	
	if (reset):
		resetA2Z()
		treeItems.clear()
		
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
		
	# process addCategory
	if (addCategory != null):
		categorys.append(addCategory)
		settings.customCategorys.append(addCategory)
	
	writeLog("categorys = " + str(categorys) + " | size = " + str(categorys.size()))
	# get_node("Tree").set_columns(categorys.size() + 1)
	get_node("MenuPanel/catOptionBtn").set_text(langNode.currLang.catOptions[0])
	get_node("WindowDialog").set_title(langNode.currLang.catOptions[1])
	get_node("WindowDialog/addCategory").set_text(langNode.currLang.catOptions[2])
	
	catTreeNode.set_columns(3)
	catTreeNode.set_column_title(0, langNode.currLang.catOptions[3])
	catTreeNode.set_column_title(1, langNode.currLang.catOptions[4])
	catTreeNode.set_column_title(2, langNode.currLang.catOptions[5])
	
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
	treeNode.set_column_title(0, langNode.currLang.string1)
	treeNode.set_column_min_width(0, 100)
	treeNode.set_column_expand(0, false)
	
	for i in range(showncategorys.size()):
		writeLog("processing category " + str(i) + " | " + str(showncategorys[i]))
		treeNode.set_column_title(i + 1, showncategorys[i])
	# get_node("Tree").set_columns(showncategorys.size() + 1)
	pass

func getRandomInt(minimal, maximum):
	randomize()
	var returnVal = randi() % maximum
	return returnVal

func getCenterPos(currentSize):
	var cWinSize = OS.get_window_size()
	var newpos = (cWinSize/2) - (currentSize/2)
	
	# writeLog("currentSize=" + str(currentSize) + " | cWinSize=" + str(cWinSize) + " | newpos=" + str(newpos))
	return newpos

func getNode(id):
	var retNode
	
	if (id == 0):
		retNode = get_node("InfoWindow")
	elif (id == 1):
		retNode = get_node("WindowDialog")
	return retNode

func setPopupPos(id):
	var selectedNode = getNode(id)
	var newpos = getCenterPos(selectedNode.get_size())
	selectedNode.set_pos(newpos)
	pass

func showPopup(id, message, title="Info"):
	writeLog("shownPopup | id=" + str(id) + " | message=" + message)
	
	var selectedNode = getNode(id)
	setPopupPos(id)
	
	writeLog(message)
	if (id == 0):
		selectedNode.get_node("infoLabel").clear()
		selectedNode.get_node("infoLabel").add_text(message)
	selectedNode.set_title(title)
	selectedNode.show()
	
	shownPopups[id] = selectedNode.is_visible()
	writeLog("showPopup --> shownPopups: " + str(shownPopups) + " | id=" + str(id) + " | selectedNode.is_visible()" + str(selectedNode.is_visible()))
	
	# get_node("Timer").set_wait_time(1)
	# if(get_node("Timer").is_active() == false):
		# get_node("Timer").start()
	pass

func mainFunc(id, printLog, value):
	
	if (printLog):writeLog("id=" + str(id) + " | value=" + str(value))
	
	if (id == -1): # testing function!
		# procSettings(false)
		toggleLog()
	elif (id == 0):
		toggleLog()
	elif (id == 1):
		if (value == true):
			writeLog("resetting lines")
			treeItems.clear()
		else:
			writeLog("unsetting old lines for editing | " + str(treeItems.size()))
			
			for i in range(treeItems.size()):
				for iCat in range(showncategorys.size()):
					if (treeItems[i] != null):
						treeItems[i].set_editable(iCat, value)
		
		writeLog("getting free letter")
		
		var freeCounter = 0
		for i in range(a2zArray.size() - 1):
			var item = a2zArray[i]
			if (item[1] == false):
				freeCounter += 1
		writeLog("freeCounter=" + str(freeCounter))
		
		if (freeCounter == 0):
			showPopup(0, langNode.currLang.notification[0])
		else:
			var proceed = false
			var randID
			while (proceed == false):
				randID = getRandomInt(0, a2zArray.size())
				
				if (a2zArray[randID][1] == false):
					a2zArray[randID][1] = true
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
		var message = ["", ""]
		if (value == 0):
			message = [loadTextFile("res://changelog.txt"), "Changelog"]
		elif (value == 1):
			setupCategorys(true, null)
		showPopup(value, message[0], message[1])
	elif (id == 3):
		setupCategorys(true, [langNode.currLang.catOptions[2], false, true, categorys.size()])
	else:
		writeLog("THE CAKE IS A LIE!!!")
	pass

func _on_Timer_timeout():
	var timerMsg = "timer is idle"
	var primMsg = false
	resizing = false
	
	settings.screenID = OS.get_current_screen()
	currPos = OS.get_screen_position(settings.screenID) + OS.get_window_position()
	var currRect = Rect2(currPos, OS.get_window_size())
	
	if (currRect.pos != settings.screen.pos):
		settings.screen.pos = currRect.pos
	
	if (currRect.size != settings.screen.size):
		timerMsg = "currRect=" + str(currRect) + " | settings.screen=" + str(settings.screen)
		resizing = true
		settings.screen.size = currRect.size
		# settings.screen = Rect2(OS.get_window_position(), OS.get_window_size())
	
	if (resizing == true):
		primMsg = true
		
		for i in range(shownPopups.size()):
			if (shownPopups[i] == true):
				timerMsg += "i=" + str(i) + " | " + str(shownPopups[i])
				setPopupPos(i)
		if (settings.screen.size.width < 800):
			OS.set_window_size(Vector2(800, settings.screen.size.height))
		if (settings.screen.size.height < 600):
			OS.set_window_size(Vector2(settings.screen.size.width, 600))
	
	if (primMsg == true):writeLog(timerMsg)
	
	pass

func _on_InfoWindow_visibility_changed():
	shownPopups[0] = get_node("InfoWindow").is_visible()
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
		
		if (categorys.size() >= 3):
			for i in range(categorys.size()):
				categorys[i][3] = i
		
		settings.customCategorys.remove(id - 3)
		
		if (settings.customCategorys.size() > 0):
			for i in range(settings.customCategorys.size()):
				settings.customCategorys[i][3] = (i + 3)
	
	setupCategorys(true, null)
	
	pass # replace with function body

func _on_log_meta_clicked( meta ):
	OS.shell_open(meta)
	pass

func _on_infoLabel_meta_clicked( meta ):
	OS.shell_open(meta)
	pass

func _on_main_exit_tree():
	procSettings(false)
	pass

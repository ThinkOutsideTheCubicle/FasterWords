extends Node
var loaded = false
var currLang

var en = {
	id				= 0,
	language		= "English",
	stockCat		= ["City", "Country", "River"],
	mainStrings		= ["source code", "license", "current releases"],
	catOptions		= ["category-options", "categories", "new category", "category", "hidden", "delete"],
	notification	= ["No letters left!"],
	string1			= "Letter"
}

var de = {
	id				= 1,
	language		= "Deutsch",
	stockCat		= ["Stadt", "Land", "Fluss"],
	mainStrings		= ["Quellcode", "Lizenz", "aktuelle Veröffendlichungen"],
	catOptions		= ["Kategorien-Optionen", "Kategorien", "neue Kategorie", "Kategorie", "versteckt", "löschen"],
	notification	= ["Keine Buchstaben mehr übrig!"],
	string1			= "Buchstabe"
}

func _ready():
	loaded = true
	pass

func getLang(id):
	if (id == 0):return en
	elif (id == 1):return de
	return "id " + str(id) + " not found"
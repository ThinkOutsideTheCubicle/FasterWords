extends Node
var loaded = false
var currLang

var de = {
	language		= "Deutsch",
	stockCat		= ["Stadt", "Land", "Fluss"],
	mainStrings		= ["Quellcode", "Lizens", "aktuelle Veröffendlichungen"],
	catOptions		= ["Kategorien-Optionen", "Kategorien", "neue Kategorie", "Kategorie", "versteckt", "löschen"],
	notification	= ["Keine Buchstaben mehr übrig!"],
	string1			= "Buchstabe"
}

var en = {
	language		= "English",
	stockCat		= ["City", "Country", "River"],
	mainStrings		= ["source code", "license", "current releases"],
	catOptions		= ["category-options", "categories", "new category", "category", "hidden", "delete"],
	notification	= ["No letters left!"],
	string1			= "Letter"
}

func _ready():
	loaded = true
	pass
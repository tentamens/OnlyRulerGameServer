extends Node

var Unit_data = "res://unitData.json"

var Game_data
var test_data = {"Stats":{ "Strength": 23}}



func _ready():
	
	var skill_data_file = File.new()
	skill_data_file.open(Unit_data, File.READ)
	var skill_data_json = JSON.parse(skill_data_file.get_as_text())
	skill_data_file.close()
	Game_data = skill_data_json.result
	
	print(Game_data)

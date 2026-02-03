extends Node

var current_area = 1
var level_path = "res://scenes/levels/"

func next_level():
	current_area += 1
	var full_path = level_path + "level_" + str(current_area) + ".tscn"
	get_tree().call_deferred("change_scene_to_file", full_path)
	print("The player has move to level " + str(current_area))

func back_level():
	current_area -= 1
	var full_path = level_path + "level_" + str(current_area) + ".tscn"
	get_tree().call_deferred("change_scene_to_file", full_path)
	print("The player has move to level " + str(current_area))

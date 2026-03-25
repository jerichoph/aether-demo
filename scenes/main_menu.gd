extends Control

var lvl1 = "res://scenes/levels/level_1.tscn"
var lvl2 = "res://scenes/levels/level_2.tscn"
var lvl3 = "res://scenes/levels/level_3.tscn"
var start = "res://scenes/level_select.tscn"
var back = "res://scenes/main_menu.tscn"

func _ready():
	MusicManager.play_track(MusicManager.menu_music)

func _on_play_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", start)
	
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_lvl_1_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", lvl1)
	
func _on_lvl_2_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", lvl2)
	
func _on_lvl_3_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", lvl3)


func _on_back_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", back)

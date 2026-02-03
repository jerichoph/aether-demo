extends CanvasLayer

class_name ui
signal game_started
var game_points = Global.current_score


@onready var game_over_screen = $Game_Over

func _ready():
	pass
	
func update_points(points: int):
	game_points = points
	
func on_game_over():
	game_over_screen.visible = true
	$Game_Over/EndScore/Points.text = "%d" % game_points
	
	
func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

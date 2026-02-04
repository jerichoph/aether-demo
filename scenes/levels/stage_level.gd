extends Node2D

var is_reloading = false
@onready var scene_transition = $SceneTransition/AnimationPlayer
@onready var ui: ui = $UI

func _ready() -> void:
	MusicManager.play_track(MusicManager.level_1_music)
	scene_transition.get_parent().get_node("ColorRect").color.a = 255
	scene_transition.play("fade_out")

	await get_tree().create_timer(0.5).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.d
func _process(delta: float) -> void:
	if !Global.playerAlive and !is_reloading:
		is_reloading = true
		scene_transition.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		update_score()
		var points = Global.previous_score
		ui.update_points(points)
		ui.on_game_over()
		

func update_score():
	Global.previous_score = Global.current_score
	if Global.current_score > Global.high_score:
		Global.high_score = Global.current_score
	Global.current_score = 0
	

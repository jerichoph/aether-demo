extends Node2D

var is_reloading = false

@onready var scene_transition = get_node_or_null("SceneTransition/AnimationPlayer")
@onready var ui = get_node_or_null("UI")

func _ready() -> void:
	var player = get_node_or_null("Player2")
	if player:
		print("Player found, initializing level...")
	else:
		print("No player found. Static scene mode.")
	
	MusicManager.play_track(MusicManager.level_1_music)

	if scene_transition != null:
		var parent = scene_transition.get_parent() 
		if parent != null:
			var rect = parent.get_node_or_null("ColorRect")
			if rect != null:
				rect.color.a = 1.0

		scene_transition.play("fade_out")
	# -------------------------------

	if Global.UI != null:
		Global.UI.update_level_display()

	await get_tree().create_timer(0.5).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Add 'scene_transition != null' to the first check
	if scene_transition != null and !Global.playerAlive and !is_reloading:
		is_reloading = true
		
		# Now it's safe to play the animation
		scene_transition.play("fade_in")
		
		await get_tree().create_timer(0.5).timeout
		update_score()
		
		var points = Global.previous_score
		
		# Check if 'ui' and 'Global.UI' exist before calling them
		if ui != null:
			ui.update_points(points)
			ui.on_game_over()
			
		if Global.UI != null:
			Global.UI.update_level_display()

func update_score():
	Global.previous_score = Global.current_score
	if Global.current_score > Global.high_score:
		Global.high_score = Global.current_score
	Global.current_score = 0
	

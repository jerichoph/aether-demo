extends Node2D

var is_reloading = false
@onready var scene_transition = $SceneTransition/AnimationPlayer
@onready var ui: ui = $UI
@onready var boss_trigger: Area2D = $BossTrigger

func _ready() -> void:
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
	
func _on_boss_trigger_body_entered(body):
	if body.is_in_group("Player"):
		$CanvasLayer/BossBar.show()
		# Initialize the bar using the correct variable names from your boss script
		$CanvasLayer/BossBar.max_value = $GolluxBoss.health_max
		$CanvasLayer/BossBar.value = $GolluxBoss.health
		# Now tell the boss to start moving and attacking
		$GolluxBoss.start_boss_fight()
		boss_trigger.queue_free()

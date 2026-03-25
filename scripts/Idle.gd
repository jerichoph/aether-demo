extends State

@onready var collision: CollisionShape2D = $"../../PlayerDetection/CollisionShape2D"
@onready var progress_bar: ProgressBar = owner.find_child("HealthBar")
@onready var damage_bar: ProgressBar = owner.find_child("DamageBar")

var player_entered: bool = false:
	set(value):
		player_entered = value
		collision.set_deferred("disabled", value)
		progress_bar.set_deferred("visible", value)
		damage_bar.set_deferred("visible", value)
		
func _on_player_detection_body_entered(body: Node2D) -> void:
	# Only trigger if it's the player and we haven't entered yet
	if player_entered or body.name != "Player2": 
		return

	# Tell the BOSS to start the music
	owner.start_boss_music() 
	player_entered = true

func transition():
	if player_entered:
		get_parent().change_state("Follow")

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
	player_entered = true

func transition():
	if player_entered:
		get_parent().change_state("Follow")

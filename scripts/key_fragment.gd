extends Area2D


@onready var gem_pickup: AudioStreamPlayer2D = $GemPickup

func _on_body_entered(body):
	if body is Player:
		Global.key_fragments += 1
		print("Keys found: ", Global.key_fragments)
		var sfx = gem_pickup
		sfx.pitch_scale = randf_range(0.7, 1.7) # This is the "magic" line
		sfx.play()
		await gem_pickup.finished

		queue_free()

extends Area2D

func _on_body_entered(body):
	if body is Player:
		Global.key_fragments += 1
		print("Keys found: ", Global.key_fragments)
		queue_free()

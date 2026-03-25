extends Area2D

var checkpoint_manager
var player

func _ready() -> void:
	checkpoint_manager = get_parent().get_node("Checkpoint_Manager")
	player = get_parent().get_node("Player2")
	
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		killPlayer()

func killPlayer():
	player.position = checkpoint_manager.last_location






#func _on_body_entered(_body: Node2D) -> void:
#	print("you died")
#	timer.start()


#func _on_timer_timeout() -> void:
	#get_tree().reload_current_scene()

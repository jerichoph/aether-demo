extends Area2D

var checkpoint_manager

func _ready() -> void:
	checkpoint_manager = get_parent().get_parent().get_node("Checkpoint_Manager")
	
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		modulate = Color(0.228, 0.798, 0.0, 1.0) 
		checkpoint_manager.last_location =  $RespawnPoint.global_position
		

extends Node

var last_location
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_node("Player2")
	last_location = player.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

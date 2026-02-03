extends Area2D


var dead = false

func _ready():
	pass
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		dead = true
		

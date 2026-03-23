extends Area2D

@onready var light_filter = $"../CanvasModulate" 
 
var outdoor_light = Color(1, 1, 1, 1)
var dungeon_darkness = Color(0.15, 0.15, 0.25, 1) 

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		fade_light(dungeon_darkness) 

		if body.has_method("set_light_active"):
			body.set_light_active(true)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		fade_light(outdoor_light)
		
		if body.has_method("set_light_active"):
			body.set_light_active(false)

func fade_light(target_color: Color):
	var tween = create_tween()
	tween.tween_property(light_filter, "color", target_color, 1.5)

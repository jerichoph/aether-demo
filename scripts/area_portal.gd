extends Area2D

@onready var collision = $CollisionShape2D
@onready var sprite = $AnimatedSprite2D # or Sprite2D

func _ready():
	monitoring = false
	collision.disabled = true
	modulate = Color(0.2, 0.2, 0.2, 0.3) 
	scale = Vector2(0.5, 0.5)

func _process(_delta):
	var target_scale = 0.5 + (Global.key_fragments * 0.25)
	scale = lerp(scale, Vector2(target_scale, target_scale), 0.1)
	
	if Global.key_fragments >= Global.keys_needed and !monitoring:
		activate_portal()

func activate_portal():
	monitoring = true
	collision.disabled = false
	modulate = Color(1, 1, 1, 1) 
	print("Portal is now STABLE!")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.key_fragments = 0
		GameManager.next_level()
 

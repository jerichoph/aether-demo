extends CharacterBody2D

var dead := false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if dead:
		velocity = Vector2.ZERO
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

	# Idle animation
	if sprite.animation != "idle":
		sprite.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "die":
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword") and not dead:
		dead = true
		sprite.play("die")
		velocity = Vector2.ZERO

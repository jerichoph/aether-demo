extends CharacterBody2D

class_name ReaperBoss
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var damage_bar: ProgressBar = $UI/DamageBar
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_number_pos = $DamageNumber
@onready var attack_area: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var bodyCollision: CollisionShape2D = $CollisionShape2D
@onready var hitBox: CollisionShape2D = $Hitbox/CollisionShape2D

@export var key_fragment: PackedScene

var health = 150   
var health_max = 150
var dead = false
var taking_damage = false
var player: CharacterBody2D
var damage_to_deal = 15

var direction : Vector2

func _ready():
	Global.reaperDamageAmount = damage_to_deal
	if health_bar:
		health_bar.max_value = health_max
		health_bar.value = health
		damage_bar.max_value = health_max
		damage_bar.value = health
		
	player = Global.playerBody
	set_physics_process(false)
	add_to_group("Enemy")

func _process(_delta):
	if dead or player == null: return
	direction = player.global_position - global_position
	if direction.x < 0:
		animated_sprite.flip_h = true
		flip_hitboxes(true)
	else:
		animated_sprite.flip_h = false
		flip_hitboxes(false)
		
		
func flip_hitboxes(is_flipped: bool):
	
	if is_flipped:
		bodyCollision.position.x = 8
		hitBox.position.x = 8
		attack_area.position.x = -25
	else:
		bodyCollision.position.x = -8
		hitBox.position.x = -8
		attack_area.position.x = 25

		
func _physics_process(delta: float) -> void:
	if dead or taking_damage: return
	
	velocity = direction.normalized() * 40
	move_and_slide()
	handle_animation()

func take_damage(damage):
	if dead: return
	health -= damage
	
	if has_node("DamageNumber"):
		DamageNumbers.display_number(damage, $DamageNumber.global_position)

	if health_bar and damage_bar:
		health_bar.value = health 

		var tween = create_tween()
		tween.tween_property(damage_bar, "value", health, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if health <= 0:
		die()
		return

	taking_damage = true
	animated_sprite.modulate = Color(5, 5, 5)
	
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)
	
	await get_tree().create_timer(0.3).timeout
	taking_damage = false

	await get_tree().create_timer(0.4).timeout
	taking_damage = false
	
	if health <= 0:
		die()

func die():
	dead = true 
	
	if key_fragment:
		var new_key = key_fragment.instantiate()
		new_key.global_position = global_position
		get_parent().add_child(new_key)
		print("Key spawned at: ", new_key.global_position)
	else:
		print("Error: No Key Scene assigned to the Boss Inspector!")
	
	if has_node("AnimationPlayer"):
		$AnimationPlayer.stop()

	animated_sprite.play("death")
	print("Playing death animation...") # Debug check
	
	if health_bar:
		health_bar.hide()
	if damage_bar:
		damage_bar.hide()
		
	set_collision_layer_value(2, false) 

	await animated_sprite.animation_finished
	await get_tree().create_timer(2.0).timeout
	queue_free()

func handle_animation():
	if dead or taking_damage:
		return
	
	if velocity.length() > 0:
		animated_sprite.play("idle")

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area == Global.playerDamageZone:
		take_damage(Global.playerDamageAmount)


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.name == "PlayerHitbox":
			var player_node = area.get_parent()
			if player_node.has_method("take_damage"):
				player_node.take_damage(damage_to_deal)

extends CharacterBody2D

class_name BatEnemy

@onready var enemy_hp_bar: ProgressBar = $EnemyHPBar
@onready var damage_number: Node2D = $DamageNumber

const speed = 50
var dir: Vector2

var is_bat_chase: bool

var player: CharacterBody2D

var health = 50
var health_max = 50
var health_min = 0
var dead = false
var taking_damage = false
var is_roaming: bool
var damage_to_deal = 10
var points_for_kill = 100

func _ready():
	is_bat_chase = true
	enemy_hp_bar.init_health(health)
	

func _process(delta):
	Global.batDamageAmount = damage_to_deal
	Global.batDamageZone = $BatDealDamageArea
	
	if Global.playerAlive:
		is_bat_chase = true
	elif !Global.playerAlive:
		is_bat_chase = false
	
	if !is_on_floor() and dead:
		handle_animation()
		await get_tree().create_timer(1.0).timeout
		self.queue_free()
	
	move(delta)
	handle_animation()

func move(delta):
	player = Global.playerBody
	if !dead:
		is_roaming = true
		if !taking_damage and is_bat_chase and Global.playerAlive:
			velocity = position.direction_to(player.position) * speed
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * -50
			velocity = knockback_dir
		else:
			velocity += dir * speed * delta
	elif dead:
		velocity.y += 10 * delta
		velocity.x = 0
	move_and_slide()

func _on_timer_timeout()-> void:
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_bat_chase:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
			
	
func choose(array):
	array.shuffle()
	return array.front()
	
func handle_animation():
	var animated_sprite = $AnimatedSprite2D
	if !dead and !taking_damage:
		animated_sprite.play("fly")
		if dir.x == 1:
			animated_sprite.flip_h = true
		elif dir.x == -1:
			animated_sprite.flip_h = false
	elif !dead and taking_damage:
		animated_sprite.play("hurt")
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		animated_sprite.play("death")
		set_collision_layer_value(1, true)
		set_collision_layer_value(2, false)
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)
		Global.current_score += points_for_kill
		

func _on_bat_hitbox_area_entered(area: Area2D) -> void:
	if area == Global.playerDamageZone:
		var damage = Global.playerDamageAmount
		take_damage(damage)
		
func take_damage(damage):
	health -= damage
	DamageNumbers.display_number(damage, damage_number.global_position)
	enemy_hp_bar.health = health
	taking_damage = true
	if health <= 0:
		health = 0
		dead = true

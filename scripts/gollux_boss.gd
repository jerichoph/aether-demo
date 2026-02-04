extends CharacterBody2D

class_name GolluxBoss

@onready var boss_hp_bar: ProgressBar = get_tree().current_scene.get_node("CanvasLayer/BossBar")
@onready var damage_number: Node2D = $DamageNumber
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $AttackTimer
@onready var smash_zone: Area2D = $SmashZone 
@export var key_fragment: PackedScene

const SPEED = 40.0
var health = 500
var health_max = 500
var dead = false
var damage_to_deal = 20
var taking_damage = false
var is_attacking = false
var is_active = false 

var player: CharacterBody2D

func _ready():
	player = Global.playerBody
	anim.play("idle")
	
func _process(delta):
	Global.golluxDamageAmount = damage_to_deal
	Global.golluxSmashZone = $SmashZone

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 980 * delta

	if is_active and !dead:
		move_logic(delta)
	elif dead:
		velocity.x = 0
		
	move_and_slide()
	handle_animation()


func start_boss_fight():
	if is_active or dead: return
	is_active = true
	
	if boss_hp_bar:
		boss_hp_bar.init_health(health) 
		boss_hp_bar.show()
		timer.start()
		print("Boss Battle Started!")

func move_logic(_delta):
	if taking_damage or is_attacking:
		velocity.x = 0
		return

	if Global.playerAlive and player:
		var direction = position.direction_to(player.position)
		velocity.x = direction.x * SPEED
		anim.flip_h = direction.x > 0
	else:
		velocity.x = 0


func perform_smash():
	is_attacking = true
	velocity.x = 0 
	
	await get_tree().create_timer(1.0).timeout 
	
	anim.play("smash")
	_deal_smash_damage()
	await get_tree().create_timer(1.2).timeout
	is_attacking = false

func _deal_smash_damage():
	var targets = smash_zone.get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("Player") and body.has_method("take_damage"):
			body.take_damage(20)

func take_damage(damage):
	if dead: return
	health -= damage
	DamageNumbers.display_number(damage, damage_number.global_position)
	
	if boss_hp_bar:
		boss_hp_bar.health = health 
	
	if !is_attacking:
		taking_damage = true
		anim.play("hurt")
		await get_tree().create_timer(0.4).timeout
		taking_damage = false
	
	if health <= 0:
		die()

func die():
	if key_fragment:
		var new_key = key_fragment.instantiate()
		new_key.global_position = global_position
		get_parent().add_child(new_key)
		print("Key spawned at: ", new_key.global_position)
	else:
		print("Error: No Key Scene assigned to the Boss Inspector!")
	dead = true
	is_active = false
	anim.play("death")
	boss_hp_bar.hide()
	set_collision_layer_value(2, false) 
	Global.current_score += 1000
	await get_tree().create_timer(2.0).timeout
	queue_free()

func handle_animation():
	if dead or taking_damage or is_attacking:
		return 
		
	if abs(velocity.x) > 0:
		anim.play("walk")
	else:
		anim.play("idle")


func _on_gollux_hitbox_area_entered(area: Area2D) -> void:
	if area == Global.playerDamageZone:
		take_damage(Global.playerDamageAmount)


func _on_attack_timer_timeout() -> void:
	if dead or !is_active:
		return
	
	var choice = randf()
	if choice > 0.5 and !is_attacking:
		perform_smash()

		
	timer.wait_time = randf_range(2.0, 4.0)
	timer.start()

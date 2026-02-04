extends CharacterBody2D
class_name Player
const SPEED = 325.0
const JUMP_VELOCITY = -570.0

@onready var scene_transition = $SceneTransition/AnimationPlayer
@onready var sword_slash: AudioStreamPlayer2D = $AttackArea/SwordSlash
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var hud: HUD
@onready var damage_number: Node2D = $DamageNumber

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attack_type: String
var current_attack: bool

var points = Global.previous_score
var health = 100
var health_max = 100
var health_min = 0
var can_take_damage: bool
var dead: bool

const DASH_SPEED = 500.0
var dashing = false
var can_dash = true

var is_hurt = false

func _ready():
	Global.playerBody = self
	current_attack = false
	dead = false
	can_take_damage = true
	Global.playerAlive = true
	var hud_node = get_tree().get_first_node_in_group("HUD")
	if hud_node is HUD:
		hud = hud_node
	else:
		push_error("The node in group 'HUD' is not actually the HUD class!")
		
	hud.init_health(health)

		
func _physics_process(delta: float) -> void:
	
	Global.playerDamageZone = attack_area
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if !dead:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_just_pressed("dash") and can_dash and velocity:
			dashing = true
			can_dash = false
			$Dash_Timer.start()
			$dash_again_timer.start()

		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if dashing:
			velocity.x = direction * DASH_SPEED
		
		if !current_attack:
			if Input.is_action_just_pressed("left_mouse"):
				current_attack = true
				if Input.is_action_just_pressed("left_mouse") and is_on_floor():
					attack_type = "single"
				else:
					attack_type = "air"
				set_damage(attack_type)
				
				handle_attack_animation(attack_type)
		handle_movement_animation(direction)
		check_hitbox()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func check_hitbox():
	var hitbox_areas = $PlayerHitbox.get_overlapping_areas()
	var damage: int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is BatEnemy:
			damage = Global.batDamageAmount
			
		if hitbox.get_parent() is GolluxBoss:
			damage = Global.golluxDamageAmount
			
	if can_take_damage and !dashing:
		take_damage(damage)
		

func take_damage(damage):
	if damage == 0 or not can_take_damage or is_hurt:
		return
	can_take_damage = false
	is_hurt = true
	health -= damage
	animated_sprite.play("hurt")
	DamageNumbers.display_number(damage, damage_number.global_position)
	hud.set_health(health)
	if health <= 0:
		health = 0
		dead = true
		handle_death_animation()
		return
	take_damage_cooldown(1.0)

	await animated_sprite.animation_finished
	is_hurt = false
			
func handle_death_animation():
	animated_sprite.play("death")
	await  get_tree().create_timer(0.5).timeout
	$Camera2D.zoom.x = 3
	$Camera2D.zoom.y = 3
	await  get_tree().create_timer(3.5).timeout
	Global.playerAlive = false
	await  get_tree().create_timer(0.5).timeout
	self.queue_free()
		
func take_damage_cooldown(wait_time):
	await  get_tree().create_timer(wait_time).timeout
	can_take_damage = true
		
func handle_movement_animation(dir):
	if is_hurt:
		return
	if is_on_floor() and !current_attack:
		if !velocity:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	elif !current_attack:
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
			
	if dashing:
		animated_sprite.play("dash")
		
	if dir > 0:
		animated_sprite.flip_h = false
		$AttackArea/CollisionShape2D.position = Vector2(46,-29.5)
		

	elif dir < 0:
		animated_sprite.flip_h = true
		$AttackArea/CollisionShape2D.position = Vector2(-46,-29.5)
	

func _on_animated_sprite_2d_animation_finished() -> void:
	current_attack = false
		
func handle_attack_animation(attack_type):
	if current_attack:
		var animation = str(attack_type,"_attack")
		animated_sprite.play(animation)
		toggle_damage_collisions(attack_type)
		var sfx = sword_slash
		sfx.pitch_scale = randf_range(0.7, 1.7) # This is the "magic" line
		sfx.play()
		await sword_slash.finished
		

func toggle_damage_collisions(attack_type):
	var damage_area_collision = attack_area.get_node("CollisionShape2D")
	var wait_time: float
	if attack_type == "air":
		wait_time = 0.7
	elif attack_type == "single":
		wait_time = 0.3
	elif attack_type == "double":
		wait_time = 0.7

	damage_area_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_area_collision.disabled = true
	
func set_damage(attack_type):
	var current_damage_to_deal: int
	if attack_type == "single":
		current_damage_to_deal = 20
	elif attack_type == "air":
		current_damage_to_deal = 40
	Global.playerDamageAmount = current_damage_to_deal
		


func _on_dash_timer_timeout() -> void:
	dashing = false


func _on_dash_again_timer_timeout() -> void:
	can_dash = true

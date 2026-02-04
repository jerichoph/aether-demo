extends CharacterBody2D
class_name Player
const SPEED = 250.0
const JUMP_VELOCITY = -510.0

@onready var aura_light = $PointLight2D
@onready var scene_transition = $SceneTransition/AnimationPlayer
@onready var sword_slash: AudioStreamPlayer2D = $AttackArea/SwordSlash
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var hud: HUD
@onready var damage_number: Node2D = $DamageNumber
@onready var hitbox: CollisionShape2D = $PlayerHitbox/CollisionShape2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attack_type: String
var current_attack: bool

var points = Global.previous_score
var health = 200
var health_max = 200
var health_min = 0
var can_take_damage: bool
var dead: bool

const DASH_SPEED = 500.0
var dashing = false
var can_dash = true

var knockback_direction = 0

var is_hurt = false
var last_direction = 0
var dash_timer = 0.0
const DOUBLE_TAP_TIME = 0.25

var wall_jump_count = 0
const MAX_WALL_JUMPS = 2

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
	
	var direction := Input.get_axis("left", "right")
	
	var pre_move_velocity = velocity.x
	
	var move_speed = SPEED * 0.5
	
	if Input.is_action_pressed("shift"): 
		move_speed = SPEED
		
	if not is_on_floor():
		if is_on_wall_only():
			var wall_normal = get_wall_normal()
			if (direction > 0 and wall_normal.x < 0) or (direction < 0 and wall_normal.x > 0):
				velocity.y = 0
			else:
				velocity.y = 100 # Slide down
		else:
			velocity.y += gravity * delta 

	if !dead:
		if is_on_floor():
			wall_jump_count = 0
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
			elif is_on_wall_only() and wall_jump_count < MAX_WALL_JUMPS:
				var wall_normal = get_wall_normal()
				animated_sprite.play("wall_jump") 
				wall_jump_count += 1
				velocity.x = wall_normal.x * (SPEED * 1.8) 
				velocity.y = JUMP_VELOCITY
				animated_sprite.flip_h = wall_normal.x < 0

		dash_timer -= delta
		if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("left"):
			var current_dir = 1 if Input.is_action_just_pressed("right") else -1
			if current_dir == last_direction and dash_timer > 0:
				if can_dash and Input.is_action_pressed("shift"):
					dashing = true
					can_dash = false
					$Dash_Timer.start()
					$dash_again_timer.start()
		
		# Reset for next check
			last_direction = current_dir
			dash_timer = DOUBLE_TAP_TIME

		if direction:
			if is_on_floor():
				velocity.x = direction * move_speed
			else:
				velocity.x = move_toward(velocity.x, direction * move_speed, SPEED * delta * 10)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if dashing:
			velocity.x = direction * DASH_SPEED
		
		# --- ATTACK ---
		if !current_attack:
			if Input.is_action_just_pressed("left_mouse"):
				current_attack = true
				if is_on_floor():
					attack_type = "single"
				else:
					attack_type = "air"
				set_damage(attack_type)
				handle_attack_animation(attack_type)

		handle_movement_animation(direction, pre_move_velocity)
		check_hitbox()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func check_hitbox():
	var hitbox_areas = $PlayerHitbox.get_overlapping_areas()
	var damage: int = 0
	
	if hitbox_areas:
		for area in hitbox_areas:
			var parent = area.get_parent()
			
			if parent is ReaperBoss:
				damage = Global.reaperDamageAmount
				var dir = global_position.x - parent.global_position.x
				knockback_direction = sign(dir) 
				break
				
			if parent is BatEnemy:
				damage = Global.batDamageAmount
				break
				
			if parent is Minion:
				damage = Global.minionDamageAmount
				break
				
	if can_take_damage and !dashing and damage > 0:

		take_damage(damage)
		

func take_damage(damage):
	if damage == 0 or not can_take_damage or is_hurt or dashing:
		return
	velocity.x = knockback_direction * 800 # Adjust force as needed
	velocity.y = -300 # Small hop upward
	
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
		
func handle_movement_animation(dir, old_vel_x):
	if is_hurt:
		return
		
	if animated_sprite.animation in ["run_turn", "walk_turn", "run_to_idle"]:
			if animated_sprite.is_playing():
				return

	if dashing:
		animated_sprite.play("dash")
		return
	else:
		hitbox.disabled = false

	if current_attack:
		return
		
	if animated_sprite.animation == "wall_jump" and animated_sprite.is_playing():
		return

	if is_on_wall_only():
		animated_sprite.flip_h = get_wall_normal().x < 0
		animated_sprite.play("wall_slide")
		return

	if is_on_floor() and dir != 0:
		if (old_vel_x > 100 and dir < 0) or (old_vel_x < -100 and dir > 0):
			print("Triggered Turn!")
			if Input.is_action_pressed("shift"):
				animated_sprite.play("run_turn")
			else:
				animated_sprite.play("walk_turn")
			return
		if dir == 0 and abs(old_vel_x) > 150:
			animated_sprite.play("run_to_idle")
			return

	# --- 3. NORMAL FLIP ---
	if dir > 0:
		animated_sprite.flip_h = false
		$AttackArea/CollisionShape2D.position = Vector2(46,-29.5)
	elif dir < 0:
		animated_sprite.flip_h = true
		$AttackArea/CollisionShape2D.position = Vector2(-46,-29.5)

	# --- 4. GROUND / AIR LOGIC ---
	if is_on_floor():
		if abs(velocity.x) < 0.1:
			animated_sprite.play("idle")
		else:
			if Input.is_action_pressed("shift"):
				animated_sprite.play("run")
			else:
				animated_sprite.play("walk")
	else:
		if velocity.y < 0:

			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	

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
		current_damage_to_deal = 30
	Global.playerDamageAmount = current_damage_to_deal
		

func set_light_active(is_active: bool):
	var tween = create_tween()
	if is_active:
		tween.tween_property(aura_light, "energy", 0.5, 0.5)
	else:
		tween.tween_property(aura_light, "energy", 0.0, 0.5)

func _on_dash_timer_timeout() -> void:
	dashing = false


func _on_dash_again_timer_timeout() -> void:
	can_dash = true

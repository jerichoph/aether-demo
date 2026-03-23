extends CharacterBody2D

class_name Minion

@onready var player: Player = Global.playerBody
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_hp_bar: ProgressBar = $EnemyHPBar
@onready var damage_number: Node2D = $DamageNumber

var health = 50
var health_max = 50
var health_min = 0
var dead = false
var taking_damage = false
var is_roaming: bool
var damage_to_deal = 5
var points_for_kill = 100

func _ready():
	Global.minionDamageAmount = damage_to_deal
	set_physics_process(false)
	await animation.animation_finished
	set_physics_process(true)
	animation.play("idle")
	
func _physics_process(_delta):
	if health <= 0:
		dead = true
		if dead:
			queue_free()
			
	if Global.playerAlive:
		var direction = player.position - position
		velocity = direction.normalized() * 60
	move_and_slide()
	

func _on_minion_hit_box_area_entered(area: Area2D) -> void:
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

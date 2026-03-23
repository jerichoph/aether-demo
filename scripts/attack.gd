extends State

@onready var hit_zone: CollisionShape2D = $"../../AttackArea/CollisionShape2D"

func enter():
	super.enter()
	combo()

func attack(move = "1"):
	animation_player.play("attack_" + move)
	await get_tree().create_timer(0.3).timeout 
	hit_zone.disabled = false
	await get_tree().create_timer(0.3).timeout 
	hit_zone.disabled = true
	
	if animation_player.is_playing():
		await animation_player.animation_finished
	
func combo():
	var move_set = ["1","1","2"]
	for i in move_set:
		if get_parent().current_state != self: 
			hit_zone.disabled = true
			return
		await attack(i)
	combo()
	
func transition():
	if owner.direction.length() > 40:
		get_parent().change_state("Follow")

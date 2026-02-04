extends ProgressBar

@onready var timer: Timer = $Timer
@onready var damage_bar = $DamageBar
@onready var health_label: Label = $HealthLabel

var health = 0 : set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = clamp(new_health, 0, max_value)
	value = health
	
	if health_label:
		health_label.text = str(int(health)) + " / " + str(int(max_value))
	
	damage_bar.max_value = max_value
	
	if health <= 0:
		hide()
	if health < prev_health:
		damage_bar.value = prev_health
		timer.start()
	else:
		damage_bar.value = health

func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health
	if health_label:
		health_label.text = str(int(health)) + "/" + str(int(max_value))
	
func change_health(new_health: int):
	_set_health(new_health)
	

func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(damage_bar, "value", health, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	

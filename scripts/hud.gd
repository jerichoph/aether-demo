extends CanvasLayer
class_name HUD
@onready var health_bar: ProgressBar = $Sprite_HP/HealthBar
@onready var damage_bar: ProgressBar = $Sprite_HP/HealthBar/DamageBar
@onready var health_label: Label = $Sprite_HP/HealthBar/HealthLabel
@onready var key_label = $KeyCounter
var game_points = Global.current_score
var default_text = "SCORE: "


func init_health(value: int):
	if not is_node_ready():
		await ready
		
	health_bar.max_value = value
	health_bar.max_value = value
	health_bar.init_health(value)
	damage_bar.max_value = value
	damage_bar.value = value


func set_health(value: int):
	health_bar.change_health(value)
	var current = str(int(health_bar.value))
	var maximum = str(int(health_bar.max_value))
	while current.length() < 3:
		current = " " + current
	health_label.text = str(current, "/", maximum)
	
func _process(_delta):
	var text = str(default_text, str(Global.current_score))
	$SCORE.text = (text)

func _ready():
	Global.UI = self
	update_key_count(Global.key_fragments)

func update_key_count(count):
	key_label.text = "Shards: " + str(count) + " / " + str(Global.keys_needed)
	
	# Visual Juice: Make the text flash gold when a key is picked up
	var tween = create_tween()
	key_label.modulate = Color(1, 0.8, 0) # Gold color
	tween.tween_property(key_label, "modulate", Color(1, 1, 1), 0.5)
	

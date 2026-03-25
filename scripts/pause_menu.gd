extends Control
var menu = "res://scenes/main_menu.tscn"
@onready var button_container = $PanelContainer/VBoxContainer 

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

	hide() 

	button_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for child in button_container.get_children():
		if child is Button:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func pause():
	show()

	button_container.mouse_filter = Control.MOUSE_FILTER_STOP
	
	for child in button_container.get_children():
		if child is Button:
			child.mouse_filter = Control.MOUSE_FILTER_STOP
			
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	
func testEsc():
	if Input.is_action_just_pressed("esc"):
		if !get_tree().paused:
			pause()
		else:
			resume()

func _on_resume_pressed() -> void:
	resume()


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	get_tree().paused = false 
	visible = false # Hide immediately
	get_tree().call_deferred("change_scene_to_file", menu)
	

func _process(delta: float) -> void:
	testEsc()

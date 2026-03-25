extends AudioStreamPlayer

var menu_music = preload("res://audio/music/menu_theme.mp3")
var level_1_music = preload("res://audio/music/level_1_theme.mp3")
var boss_music = preload("res://audio/music/bossbattle3.mp3")
# Change this value to set your "Max" desired volume (e.g., -15.0 for quiet)
@export var target_volume: float = -20.0 

func play_track(track_stream: AudioStream):
	if stream == track_stream and playing:
		return 
		
	stream = track_stream
	
	# 1. Start even quieter than the target so it can fade IN
	volume_db = target_volume - 20.0 
	play()
	
	# 2. Fade to your target_volume over 1.5 seconds
	var tween = create_tween()
	# Use target_volume here instead of 0.0
	tween.tween_property(self, "volume_db", target_volume, 1.5) 

func stop_music():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, 1.0) # Fade to total silence
	tween.tween_callback(stop)

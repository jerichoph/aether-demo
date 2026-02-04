extends AudioStreamPlayer

# Add your music files here
var menu_music = preload("res://audio/music/menu_theme.mp3")
var level_1_music = preload("res://audio/music/level_1_theme.mp3")

func play_track(track_stream: AudioStream):
	volume_db = -15.0 
	if stream == track_stream and playing:
		return 
		
	stream = track_stream
	play()

func stop_music():
	stop()

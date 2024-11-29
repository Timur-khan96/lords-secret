extends AudioStreamPlayer

var day_music_arr = [
	load("res://audio/music/vampire_determination.ogg"),
	load("res://audio/music/vampire_melancholy.ogg"),
	load("res://audio/music/vampire_serenity.ogg"),
	load("res://audio/music/village_rise.ogg")
]
var curr_day_music_arr = []

var night_music_arr = [
	load("res://audio/music/vampire_darkness.ogg"),
	load("res://audio/music/vampire_tension.ogg")
]
var curr_night_music_arr = []

func play_day_music():
	if curr_day_music_arr.is_empty():
		curr_day_music_arr = day_music_arr.duplicate()
	if !playing:
		stream = curr_day_music_arr.pick_random()
		curr_day_music_arr.erase(stream)
		play()
		
func play_night_music():
	if curr_night_music_arr.is_empty():
		curr_night_music_arr = night_music_arr.duplicate()
	if !playing:
		stream = curr_night_music_arr.pick_random()
		curr_night_music_arr.erase(stream)
		play()

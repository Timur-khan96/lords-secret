extends AudioStreamPlayer3D

var voice_path

func play_sound(sound):
	bus = "SFX"
	match sound:
		"scream":
			match randi_range(0,2):
				0:
					stream = load(voice_path + "scream_1.mp3")
				1:
					stream = load(voice_path + "scream_2.mp3")
				2:
					return
		"chop":
			match randi_range(0,2):
				0:
					stream = load("res://audio/SFX/chop_1.mp3")
				1:
					stream = load("res://audio/SFX/chop_2.mp3")
				2:
					stream = load("res://audio/SFX/chop_3.mp3")
		"hammer":
			match randi_range(0,2):
				0:
					stream = load("res://audio/SFX/hammer_1.mp3")
				1:
					stream = load("res://audio/SFX/hammer_2.mp3")
				2:
					stream = load("res://audio/SFX/hammer_3.mp3")
	play()
	
func play_voice(current_dialogue):
	bus = "Voice"
	stream = load(voice_path + current_dialogue + ".mp3")
	play()

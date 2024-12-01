extends AudioStreamPlayer

func play_sound(sound_name):
	match sound_name:
		"hurt":
			if randf() < 0.5:
				stream = load("res://audio/SFX/lord_hurt_1.mp3")
			else:
				stream = load("res://audio/SFX/lord_hurt_2.mp3")
		"lord_attack":
			stream = load("res://audio/SFX/lord_attack.mp3")
	if !playing: play()

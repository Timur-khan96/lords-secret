extends StaticBody3D

var visited_this_night = false #visited but didn't open door
var visitor_opened_door = false #to prevent closing after nightime opening
var opened = false

func open_doors():
	if !opened:
		opened = true
		$door_sound.stream = load("res://audio/SFX/door_open.mp3")
		$door_sound.play()
		$door_anim.play("open");
		get_tree().create_timer(2).timeout.connect(close_doors)
	
func close_doors():
	$door_sound.stream = load("res://audio/SFX/door_closed.mp3")
	$door_sound.play()
	opened = false
	$door_anim.play_backwards("open");
	
func interact():
	if is_in_group("villager_doors"):
		if WorldUtility.is_daytime:
			open_doors()
		else:
			if get_parent().has_owner_inside():
				if visitor_opened_door:
					open_doors()
				else:
					var o = get_parent().house_owner
					if visited_this_night || o.in_danger:
						o.play_voice("nightime_door_dialogue_2")
						Global.start_dialogue("nightime_door_dialogue_2")
					else:
						o.play_voice("nightime_door_dialogue")
						Global.start_dialogue("nightime_door_dialogue")
						Dialogic.timeline_ended.connect(_on_nightime_dialogue_ended)
			else:
				open_doors()
	else:
		open_doors()
			
func _on_nightime_dialogue_ended():
	Dialogic.timeline_ended.disconnect(_on_nightime_dialogue_ended)
	if Dialogic.VAR.is_villager_opening_door:
		visitor_opened_door = true
		open_doors()
		get_parent().nightime_door_open()
	else:
		visited_this_night = true

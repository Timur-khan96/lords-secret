extends StaticBody3D

var visited_this_night = false #visited but didn't open door
var visitor_opened_door = false #to prevent closing after nightime opening

func open_doors():
	$door_anim.play("open");
	get_tree().create_timer(2).timeout.connect(close_doors)
		
func open_doors_daytime():
	$door_anim.play("open_door_daytime")
	get_tree().create_timer(2).timeout.connect(close_doors)
	
func close_doors():
	$door_anim.play_backwards("open");
	if !is_in_group("villager_doors"): #mansion door then
		var p = get_parent()
		if p.petitioner_is_leaving:
			p.petitioner_is_leaving = false
			p.petitioner = null
	
func interact():
	if is_in_group("villager_doors"):
		if WorldUtility.is_daytime:
			open_doors_daytime()
		else:
			if get_parent().has_owner():
				if visitor_opened_door:
					open_doors()
				else:
					if visited_this_night:
						Global.start_dialogue("nightime_door_dialogue_2")
					else:
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

extends StaticBody3D

var is_mansion_door = false

func open_doors():
	$door_anim.play("open");
	get_tree().create_timer(2).timeout.connect(close_doors)
	
func close_doors():
	$door_anim.play_backwards("open");
	if is_mansion_door:
		var p = get_parent()
		if p.petitioner_is_leaving:
			p.petitioner_is_leaving = false
			p.petitioner = null
	
func interact():
	if is_mansion_door:
		open_doors()
	else:
		print("talk with the owner at night")

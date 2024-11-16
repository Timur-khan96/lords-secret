extends StaticBody3D

func open_doors():
	$door_anim.play("open");
	get_tree().create_timer(2).timeout.connect(close_doors)
	
func close_doors():
	$door_anim.play_backwards("open");
	
func interact():
	open_doors()

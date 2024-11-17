extends StaticBody3D

func interact():
	get_parent().pop_mansion_queue()

func bell_ring():
	$AnimationPlayer.play("ring")

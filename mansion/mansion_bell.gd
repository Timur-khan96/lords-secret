extends StaticBody3D

var ringing = false

func interact():
	get_parent().pop_mansion_queue()

func bell_ring():
	if !ringing:
		ringing = true
		$AnimationPlayer.play("ring")
		$bell_ringing.play()

func _on_animation_player_animation_finished(_anim_name):
	ringing = false

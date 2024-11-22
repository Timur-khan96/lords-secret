extends Node3D

var stump = load("res://world/models/stump.glb")

var health = 6;

func hit(): #returns true if the blow is final
	if health == 0: return
	health -= 1;
	if health == 0:
		$AnimationPlayer.play("fall")
		$death_timer.start()
		var s = stump.instantiate()
		get_parent().add_child(s)
		s.global_position = global_position
		return true
	else:
		$AnimationPlayer.play("shake")
		return false
		
		


func _on_death_timer_timeout():
	queue_free()

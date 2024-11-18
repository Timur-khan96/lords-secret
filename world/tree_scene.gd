extends Node3D

var health = 10;

func hit():
	if health == 0: return
	health -= 1;
	if health == 0:
		$AnimationPlayer.play("fall")
	else:
		$AnimationPlayer.play("hit")

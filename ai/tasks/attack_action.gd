extends ActionLeaf

var status = 0 #enum-like: 0-not started 1 running 2 finished

func tick(actor, blackboard: Blackboard):
	if !actor.check_anim("attack") && status == 0:
		var direction = (blackboard.get_value("destination") - actor.global_position).normalized()
		direction.y = 0
		actor.look_at(actor.global_position + direction, Vector3.UP)
		actor.show_attached("axe")
		actor.play_animation("attack")
		status = 1
		get_tree().create_timer(0.8).timeout.connect(_on_hit)
		return RUNNING
	elif status == 1:
		return RUNNING
	elif status == 2:
		status = 0
		blackboard.get_value("attack_target").hit() #subject of change
		return SUCCESS
	
func _on_hit():
	status = 2

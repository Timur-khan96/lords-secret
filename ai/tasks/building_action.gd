extends ActionLeaf

var status = 0 #enum-like: 0-not started 1 running 2 finished

func tick(actor, blackboard: Blackboard):
	if !actor.check_anim("attack") && status == 0:
		actor.look_at(blackboard.get_value("destination"), Vector3.UP)
		actor.show_attached("hammer")
		actor.play_animation("attack")
		status = 1
		get_tree().create_timer(0.8).timeout.connect(_on_finished)
		return RUNNING
	elif status == 1:
		return RUNNING
	elif status == 2:
		actor.play_sound("hammer")
		status = 0
		var result = blackboard.get_value("house").build_iteration()
		if result: #building is done
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
			actor.hide_attached("hammer")
		return SUCCESS
	
func _on_finished():
	status = 2
	

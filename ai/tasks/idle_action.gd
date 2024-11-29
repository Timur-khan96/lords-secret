extends ActionLeaf

var status = 0 #enum-like: 0-not started 1 running 2 finished

func tick(actor, blackboard: Blackboard):
	if blackboard.get_value("occupation") != NpcUtility.OCCUPATIONS.IDLE:
		return FAILURE
	if status == 0:
		var a = blackboard.get_value("idle_animation")
		if !actor.check_anim(a):
			status = 1
			actor.play_animation(a)
			actor.anim_controller.anim_finished.connect(_on_finished)
		return RUNNING
	elif status == 1:
		return RUNNING
	else:
		actor.anim_controller.anim_finished.disconnect(_on_finished)
		status = 0
		return SUCCESS
		
func _on_finished():
	status = 2

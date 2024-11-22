extends ActionLeaf

func tick(actor, _blackboard: Blackboard):
	if !actor.check_anim("sleep"):
		actor.play_animation("sleep")
	return SUCCESS

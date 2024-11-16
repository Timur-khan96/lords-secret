extends ActionLeaf

func tick(actor, _blackboard: Blackboard):
	if !actor.check_anim("talk"):
		actor.play_animation("talk")
	return SUCCESS

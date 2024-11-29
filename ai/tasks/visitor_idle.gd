extends ActionLeaf

func tick(actor, _blackboard: Blackboard):
	if !actor.check_anim("idle"):
		actor.play_animation("idle")
	return SUCCESS

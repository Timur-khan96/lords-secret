extends ActionLeaf

func tick(actor, blackboard: Blackboard):
	if WorldUtility.is_daytime:
		blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
		return SUCCESS
	else:
		if !actor.check_anim("sleep"):
			actor.play_animation("sleep")
		if blackboard.get_value("awakened"):
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
			return FAILURE
		return RUNNING

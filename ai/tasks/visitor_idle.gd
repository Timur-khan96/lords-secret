extends ActionLeaf

func tick(actor, blackboard: Blackboard):
	if blackboard.get_value("occupation") != NpcUtility.OCCUPATIONS.IDLE || actor.in_danger:
		return FAILURE
	if !actor.check_anim("idle"):
		actor.play_animation("idle")
	return SUCCESS

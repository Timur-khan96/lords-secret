extends ConditionLeaf
#for enemy to talk before attacking

func tick(actor, blackboard: Blackboard):
	if blackboard.get_value("occupation") != NpcUtility.OCCUPATIONS.ATTACKING:
		if actor.petitioner_dialogue == null:
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
			return FAILURE
		else:
			return SUCCESS
	else:
		return FAILURE

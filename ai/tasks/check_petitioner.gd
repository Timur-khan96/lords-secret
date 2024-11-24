extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.game_info.status == NpcUtility.NPC_Status.PETITIONER:
		return SUCCESS
	else:
		if blackboard.get_value("occupation") != NpcUtility.OCCUPATIONS.IDLE:
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
		return FAILURE

extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	match actor.game_info.status:
		NpcUtility.NPC_Status.PETITIONER:
			return SUCCESS
		NpcUtility.NPC_Status.VISITOR:
			if blackboard.get_value("occupation") != NpcUtility.OCCUPATIONS.IDLE:
				blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
			return FAILURE
		_:
			return FAILURE

extends ConditionLeaf

func tick(_actor, blackboard: Blackboard):
	if blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.SLEEPING:
		return SUCCESS
	else:
		return FAILURE

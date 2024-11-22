extends ConditionLeaf

func tick(_actor, blackboard: Blackboard):
	if blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.GATHERING:
		return SUCCESS
	else:
		return FAILURE

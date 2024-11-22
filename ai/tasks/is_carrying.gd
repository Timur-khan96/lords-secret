extends ConditionLeaf

func tick(_actor, blackboard: Blackboard):
	if blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.CARRYING:
		return SUCCESS
	else:
		return FAILURE

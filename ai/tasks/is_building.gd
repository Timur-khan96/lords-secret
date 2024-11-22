extends ConditionLeaf

func tick(_actor, blackboard: Blackboard):
	if blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.BUILDING:
		return SUCCESS
	else:
		return FAILURE

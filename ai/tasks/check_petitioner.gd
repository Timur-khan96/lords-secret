extends ConditionLeaf


func tick(_actor, blackboard: Blackboard):
	if blackboard.get_value("is_petitioner"):
		return SUCCESS
	else:
		return FAILURE

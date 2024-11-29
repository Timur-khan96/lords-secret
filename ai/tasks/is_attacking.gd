extends ConditionLeaf

func tick(actor, blackboard: Blackboard):
	if !actor.is_combatant: return FAILURE
	if blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.ATTACKING:
		return SUCCESS
	else:
		return FAILURE

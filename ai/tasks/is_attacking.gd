extends ConditionLeaf

const POS_Y = 0.6

func tick(actor, blackboard: Blackboard):
	if !actor.is_combatant: return FAILURE
	if blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.ATTACKING:
		var t = blackboard.get_value("attack_target").global_position
		t.y = POS_Y
		if actor.global_position.distance_to(t) <= blackboard.get_value("desired_distance"):
			return SUCCESS
		else:
			blackboard.set_value("destination", t)
			return FAILURE
	else:
		return FAILURE

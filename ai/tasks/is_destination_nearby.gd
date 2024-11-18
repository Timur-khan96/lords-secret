extends ConditionLeaf

func tick(actor, blackboard: Blackboard):
	var dest = blackboard.get_value("destination")
	var dist = blackboard.get_value("desired_distance")
	if actor.global_position.distance_to(dest) > dist:
		print("need to move")
		actor.nav_agent.target_position = dest
		actor.nav_agent.target_desired_distance = dist;
		return FAILURE
	else:
		return SUCCESS

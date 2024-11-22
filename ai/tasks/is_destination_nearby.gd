extends ConditionLeaf

func tick(actor, blackboard: Blackboard):
	var dest = blackboard.get_value("destination")
	var dist = blackboard.get_value("desired_distance")
	if actor.global_position.distance_to(dest) > dist:
		if actor.nav_agent.target_position != dest:
			actor.nav_agent.target_position = dest
			#actor.nav_agent.target_desired_distance = dist;
			print("setting nav_agent in the tree")
		return FAILURE
	else:
		actor.velocity = Vector3.ZERO #we exit movement before navigation finished
		return SUCCESS

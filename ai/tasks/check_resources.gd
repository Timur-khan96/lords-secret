extends ConditionLeaf

func tick(_actor, blackboard: Blackboard):
	if blackboard.has_value("house"):
		var h = blackboard.get_value("house")
		if h.resources >= 0.1:
			blackboard.set_value("destination", h.global_position)
			blackboard.set_value("desired_distance", 3.0)
			return SUCCESS #staying here cause we can build
		else:
			return FAILURE #moving out cause need resources
	else:
		print("couldn't find house in blackboard")
		return FAILURE

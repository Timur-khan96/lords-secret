extends ConditionLeaf

func tick(_actor, blackboard: Blackboard):
	if blackboard.has_value("house"):
		var h = blackboard.get_value("house")
		if h.resources == 1.0:
			blackboard.set_value("is_gathering", false)
			blackboard.set_value("destination", h.global_position)
			blackboard.set_value("desired_distance", 3.0)
			return SUCCESS #staying here cause we can build
		elif !blackboard.get_value("is_gathering"):
			blackboard.set_value("is_gathering", true)
			blackboard.set_value("resource", "wood")
			blackboard.set_value("source", null)
			blackboard.set_value("resource_storage", h.global_position)
			return FAILURE #moving out cause need resources
		elif blackboard.get_value("is_gathering"):
			return FAILURE
	else:
		print("couldn't find house in blackboard")
		return FAILURE

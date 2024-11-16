extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	var a = actor.nav_agent
	if a.is_navigation_finished():
		var d = blackboard.get_value("destination")
		if d: 
			if d == a.target_position:
				actor.has_arrived = true;
				return FAILURE #we are where we need to be
			else:
				actor.has_arrived = false;
				a.target_position = d
				return SUCCESS #we are moving
		else:
			print("Couldn't get destination from blackboard")
			return FAILURE
	else:
		return SUCCESS

extends ConditionLeaf

var curr_destination = null

func tick(actor, blackboard: Blackboard):
	var a = actor.nav_agent
	if a.is_navigation_finished():
		if curr_destination:
			var d = blackboard.get_value("destination")
			if curr_destination == d:
				actor.has_arrived = true;
				return FAILURE
			else:
				curr_destination = d
				return set_nav_agent(actor,a, blackboard.get_value("desired_distance"))
		else:
			curr_destination = blackboard.get_value("destination")
			return set_nav_agent(actor, a, blackboard.get_value("desired_distance"))
	else:
		return SUCCESS
		
func set_nav_agent(actor, nav_agent, desired_distance) -> int:
	curr_destination.y = 0.6
	if curr_destination == nav_agent.target_position:
		actor.has_arrived = true;
		return FAILURE #we are where we need to be
	else:
		actor.has_arrived = false;
		nav_agent.target_position = curr_destination
		nav_agent.target_desired_distance = desired_distance
		return SUCCESS #we are moving
	

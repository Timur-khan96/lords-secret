extends ConditionLeaf

var curr_destination = null
const POS_Y = 0.6

func tick(actor, blackboard: Blackboard):
	var a = actor.nav_agent
	if a.is_navigation_finished():
		if curr_destination:
			var d = blackboard.get_value("destination")
			d.y = POS_Y
			if curr_destination == d:
				return FAILURE #we are where we need to be
			else:
				curr_destination = d
				return set_nav_agent(a, blackboard.get_value("desired_distance"))
		else:
			curr_destination = blackboard.get_value("destination")
			return set_nav_agent(a, blackboard.get_value("desired_distance"))
	else: #might change destination if lord attacked, for example
		var d = blackboard.get_value("destination")
		d.y = POS_Y
		if curr_destination != d:
			curr_destination = d
			set_nav_agent(a, blackboard.get_value("desired_distance"))
		return SUCCESS
		
func set_nav_agent(nav_agent, desired_distance) -> int:
	curr_destination.y = POS_Y
	if curr_destination == nav_agent.target_position:
		return FAILURE #we are where we need to be
	else:
		nav_agent.target_position = curr_destination
		nav_agent.target_desired_distance = desired_distance
		return SUCCESS #we are moving
	

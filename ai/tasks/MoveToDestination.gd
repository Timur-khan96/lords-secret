extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var new_pos = actor.nav_agent.get_next_path_position()
	var curr_pos = actor.global_position
	actor.velocity = (new_pos - curr_pos).normalized() * actor.speed
	return SUCCESS

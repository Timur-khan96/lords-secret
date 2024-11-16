extends ConditionLeaf


#
#@export var dest_var: StringName = &"destination"
#
func tick(actor: Node, blackboard: Blackboard) -> int:
	var dest = blackboard.get_value("destination")
	if dest:
		if actor.global_position.distance_to(dest) < 1:
			actor.velocity = Vector3.ZERO
			#agent.queue_free() for debug purposes
			return FAILURE #change to idle sequence
		else:
			return SUCCESS #stay in moving sequence
	else:
		print("Couldn't get destination from blackboard")
		return FAILURE

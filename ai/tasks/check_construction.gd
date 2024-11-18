extends ConditionLeaf

func tick(_actor, blackboard: Blackboard):
	if blackboard.has_value("house"):
		if blackboard.get_value("house").construction < 1.0:
			return SUCCESS
		else:
			queue_free.call_deferred()
			print("finished cosntruction")
			return FAILURE
	else:
		print("couldn't find house in blackboard")
		return FAILURE

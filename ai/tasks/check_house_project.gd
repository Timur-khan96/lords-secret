extends ConditionLeaf

var finished = false

func tick(_actor, blackboard: Blackboard):
	if blackboard.has_value("plot"):
		if !blackboard.get_value("plot").has_house:
			blackboard.set_value("house", 
			PlotUtility.put_house_project(blackboard.get_value("plot")))
			finished = true
			return SUCCESS
		else:
			return FAILURE
	else:
		print("there is no plot in blackboard")
		return FAILURE
	
func after_run(_actor, _blackboard):
	if finished:
		queue_free.call_deferred()

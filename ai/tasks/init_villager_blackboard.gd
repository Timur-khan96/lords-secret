extends ConditionLeaf
#this is one-time action so it is used to set the initial values for blackboard

func tick(_actor, blackboard: Blackboard):
	blackboard.set_value("carrying_resources", 0.0)
	blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
	blackboard.set_value("is_nightime", false)
	if blackboard.has_value("plot"):
		var plot = blackboard.get_value("plot")
		if plot.house == null:
			blackboard.set_value("house", 
			PlotUtility.put_house_project(plot))
		else:
			blackboard.set_value("house", plot.house)
	else:
		print("there is no plot in blackboard")
	return SUCCESS
	
func after_run(_actor, _blackboard):
	queue_free.call_deferred()

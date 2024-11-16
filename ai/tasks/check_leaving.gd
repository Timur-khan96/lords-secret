extends ConditionLeaf


func tick(_actor, blackboard: Blackboard):
	if !blackboard.has_value("is_leaving"):
		blackboard.set_value("is_leaving", false)
	return FAILURE
		
func after_run(actor, blackboard):
	if blackboard.get_value("is_leaving"):
		actor.queue_free.call_deferred()

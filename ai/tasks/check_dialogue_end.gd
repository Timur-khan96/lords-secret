extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if !blackboard.has_value("dialogue_ended"):
		blackboard.set_value("dialogue_ended", false)

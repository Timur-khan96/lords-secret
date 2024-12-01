extends ConditionLeaf #it is more like an action, but beehave doesn't care as far as i know

func tick(actor, blackboard: Blackboard):
	if actor.game_info.status == NpcUtility.NPC_Status.LEAVING:
		if blackboard.has_value("plot"):
			blackboard.get_value("plot").nullify_owner() #maybe subject of change
		if actor.in_danger:
			Global.village_reputation -= 5
		if actor.get_parent() == NpcUtility.band:
			if NpcUtility.band.get_children().size() == 1:
				NpcUtility.band.queue_free.call_deferred()
				NpcUtility.band = null
		actor.queue_free.call_deferred()
	return FAILURE

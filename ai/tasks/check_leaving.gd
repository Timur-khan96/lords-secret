extends ConditionLeaf #it is more like an action, but beehave doesn't care as far as i know

var finished = false

func tick(actor, blackboard: Blackboard):
	if actor.game_info.status == NpcUtility.NPC_Status.LEAVING:
		if blackboard.has_value("plot"):
			blackboard.get_value("plot").plot_game_info.owner = null #maybe subject of change
		if actor.in_danger:
			Global.village_reputation -= 5
		actor.queue_free.call_deferred()
	elif actor.game_info.status == NpcUtility.NPC_Status.VILLAGER && !finished:
		NpcUtility.set_as_villager(actor)
		finished = true #to do it one time, i guess
	return FAILURE

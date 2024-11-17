extends ConditionLeaf

var finished = false

func tick(actor, _blackboard: Blackboard):
	if actor.game_info.status == NpcUtility.NPC_Status.LEAVING:
		actor.queue_free.call_deferred()
	elif actor.game_info.status == NpcUtility.NPC_Status.VILLAGER && !finished:
		NpcUtility.set_as_villager(actor)
		finished = true
	return FAILURE

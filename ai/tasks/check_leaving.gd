extends ConditionLeaf

var finished = false

func tick(actor, _blackboard: Blackboard):
	if actor.game_info.status == NpcUtility.NPC_Status.LEAVING:
		actor.queue_free.call_deferred()
		if actor.in_danger:
			Global.village_reputation -= 5
	elif actor.game_info.status == NpcUtility.NPC_Status.VILLAGER && !finished:
		NpcUtility.set_as_villager(actor)
		finished = true #to do it one time, i guess
	return FAILURE

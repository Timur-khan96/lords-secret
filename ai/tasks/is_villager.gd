extends ConditionLeaf
#this task is responsible for switching visitor and behavior trees

func tick(actor, _blackboard: Blackboard):
	if actor.game_info.status == NpcUtility.NPC_Status.VILLAGER:
		NpcUtility.set_as_villager(actor)

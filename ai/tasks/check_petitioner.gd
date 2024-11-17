extends ConditionLeaf


func tick(actor, _blackboard: Blackboard):
	if actor.game_info.status == NpcUtility.NPC_Status.PETITIONER:
		return SUCCESS
	else:
		return FAILURE

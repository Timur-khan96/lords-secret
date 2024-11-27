extends ActionLeaf
#visitor dialogue

func tick(actor, _blackboard: Blackboard):
	if Dialogic.current_timeline == null:
		var v = Dialogic.VAR.visitor
		var g = actor.game_info
		v.name = g.name
		v.surname = g.surname
		v.family_size = g.family_size
		v.money = g.money
		actor.look_at(Global.lord.global_position, Vector3.UP)
		Global.start_dialogue(actor.petitioner_dialogue)
	return SUCCESS
	
func after_run(_actor, _blackboard):
	queue_free.call_deferred()

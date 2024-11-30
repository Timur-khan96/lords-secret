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
		var direction = (Global.lord.global_position - actor.global_position).normalized()
		direction.y = 0
		actor.look_at(actor.global_position + direction, Vector3.UP)
		actor.play_voice("visitor")
		Global.start_dialogue(actor.petitioner_dialogue)
	return SUCCESS
	
func after_run(_actor, _blackboard):
	queue_free.call_deferred()

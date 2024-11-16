extends ActionLeaf


func tick(actor, _blackboard: Blackboard):
	if Dialogic.current_timeline == null:
		var v = Dialogic.VAR.visitor
		var g = actor.game_info
		v.name = g.name
		v.surname = g.surname
		v.family_size = g.family_size
		v.money = g.money
		Global.start_dialogue("visitor_1")
	return SUCCESS
	
func after_run(_actor, _blackboard):
	queue_free.call_deferred()

extends ActionLeaf

var status = 0 #enum-like: 0-not started 1 running 2 finished
var hunger_left: int = 10

func tick(actor, blackboard: Blackboard):
	if !actor.check_anim("attack") && status == 0:
		actor.look_at(blackboard.get_value("destination"), Vector3.UP)
		actor.play_animation("eat")
		status = 1
		actor.anim_controller.anim_finished.connect(_on_finished)
		return RUNNING
	elif status == 1:
		return RUNNING
	elif status == 2:
		status = 0
		var result = blackboard.get_value("source").eat()
		hunger_left -= 2
		if hunger_left <= 0:
			blackboard.set_value("is_hungry", false)
			actor.reload_hunger_timer()
			hunger_left = 10 #for next time
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
		if result: # is true when basket is empty
			blackboard.get_value("plot").food_storage = null
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
		actor.anim_controller.anim_finished.disconnect(_on_finished)
		return SUCCESS
	
func _on_finished():
	status = 2

extends ActionLeaf

var status = 0 #enum-like: 0-not started 1 running 2 finished
var resources_gathered: int = 0

func tick(actor, blackboard: Blackboard):
	if !actor.check_anim("attack") && status == 0:
		actor.look_at(blackboard.get_value("destination"), Vector3.UP)
		actor.play_animation("gather")
		status = 1
		actor.anim_controller.anim_finished.connect(_on_finished)
		return RUNNING
	elif status == 1:
		return RUNNING
	elif status == 2:
		status = 0
		var result = blackboard.get_value("source").gather()
		resources_gathered += 1
		if resources_gathered == 10:
			blackboard.set_value("carrying_resources", resources_gathered)
			resources_gathered = 0
		if result: #returns true only if this tree is empty
			blackboard.set_value("carrying_resources", resources_gathered)
		actor.anim_controller.anim_finished.disconnect(_on_finished)
		return SUCCESS
	
func _on_finished():
	status = 2

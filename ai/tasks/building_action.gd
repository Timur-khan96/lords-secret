extends ActionLeaf

var status = 0 #enum-like: 0-not started 1 running 2 finished

func tick(actor, blackboard: Blackboard):
	if !actor.check_anim("attack") && status == 0:
		actor.look_at(blackboard.get_value("destination"), Vector3.UP)
		actor.show_attached("hammer")
		actor.play_animation("attack")
		status = 1
		actor.anim_controller.anim_finished.connect(_on_finished)
		return RUNNING
	elif status == 1:
		return RUNNING
	elif status == 2:
		status = 0
		blackboard.get_value("house").build_iteration()
		actor.anim_controller.anim_finished.disconnect(_on_finished)
		return SUCCESS
	
func _on_finished():
	status = 2
	
func after_run(actor, _blackboard):
	actor.hide_attached("hammer")

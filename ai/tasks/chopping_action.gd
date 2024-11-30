extends ActionLeaf

var status = 0 #enum-like: 0-not started 1 running 2 finished

func tick(actor, blackboard: Blackboard):
	if !actor.check_anim("attack") && status == 0:
		actor.look_at(blackboard.get_value("destination"), Vector3.UP)
		actor.show_attached("axe")
		actor.play_animation("attack")
		status = 1
		get_tree().create_timer(0.8).timeout.connect(_on_hit)
		return RUNNING
	elif status == 1:
		return RUNNING
	elif status == 2:
		actor.play_sound("chop")
		status = 0
		var result = blackboard.get_value("source").hit() #subject of change
		if result: 
			blackboard.set_value("carrying_resources", {
				"type":"planks",
				"capacity":2
			})
			actor.hide_attached("axe")
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
		return SUCCESS
	
func _on_hit():
	status = 2

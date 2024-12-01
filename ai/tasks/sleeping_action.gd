extends ActionLeaf

var started_sleeping = false #for changing y-axis position
var sleep_rotation = Vector3(deg_to_rad(-5.4),deg_to_rad(122.1),deg_to_rad(-8.6))
var original_rotation

func tick(actor, blackboard: Blackboard):
	if WorldUtility.is_daytime:
		blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
		if started_sleeping:
			started_sleeping = false
			actor.transform.basis = original_rotation
			actor.global_position.y -= 0.5
		return SUCCESS
	else:
		if !actor.check_anim("sleep"):
			actor.play_animation("sleep")
		if blackboard.get_value("house").construction_finished:
			if !started_sleeping:
				actor.global_position = blackboard.get_value("house").bed.global_position
				var sleep_rotation_basis = Basis.from_euler(sleep_rotation)
				original_rotation = actor.transform.basis
				actor.transform.basis = sleep_rotation_basis * blackboard.get_value("house").global_transform.basis
				started_sleeping = true
				actor.global_position.y += 0.5
		if blackboard.get_value("awakened"):
			if started_sleeping:
				started_sleeping = false
				actor.transform.basis = original_rotation
				actor.global_position.y -= 0.5
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
			if !actor.in_danger:
				get_tree().create_timer(20).timeout.connect(actor._falling_back_to_sleep)
			return FAILURE
		return RUNNING

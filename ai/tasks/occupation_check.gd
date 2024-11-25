extends ConditionLeaf

func tick(actor, blackboard: Blackboard):
	var curr_occup = blackboard.get_value("occupation")
	if actor.game_info.status == NpcUtility.NPC_Status.LEAVING:
		if !curr_occup == NpcUtility.OCCUPATIONS.LEAVING:
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.LEAVING)
			blackboard.set_value("destination", WorldUtility.get_random_point_outside_bounds())
	elif curr_occup == NpcUtility.OCCUPATIONS.IDLE:
		if !is_sleep_time(blackboard):
			if !is_eat_time(actor, blackboard):
				if !blackboard.get_value("house").construction_finished:
					handle_house_construction(actor, blackboard)
					#otherwise we are idle (WIP)
	return FAILURE
			
func is_sleep_time(blackboard) -> bool:
	if !WorldUtility.is_daytime:
		blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.SLEEPING)
		blackboard.set_value("destination", 
		blackboard.get_value("plot").plot_game_info.center)
		return true
	else:
		return false
		
func is_eat_time(actor, blackboard) -> bool:
	if blackboard.get_value("is_hungry"):
		if blackboard.get_value("plot").food_storage == null:
			if blackboard.get_value("carrying_resources") > 0:
				set_carrying("apple_basket", 1.0, blackboard, actor)
				return true
			else:
				var source = get_closest_apple_tree(actor.global_position)
				if source:
					blackboard.set_value("source", source)
					blackboard.set_value("destination", source.global_position)
					blackboard.set_value("desired_distance", 1.0)
					blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.GATHERING)
					blackboard.set_value("resource_storage", 
						PlotUtility.get_random_point_in_polygon(
							blackboard.get_value("plot").get_corners_2D()
					))
					return true
				else:
					#we are fcked no apples left or a bug, good luck
					return false
		else:
			var food_source = blackboard.get_value("plot").food_storage
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.EATING)
			blackboard.set_value("destination", food_source.global_position)
			blackboard.set_value("source", food_source)
			blackboard.set_value("desired_distance", 1.0)
			return true
	else:
		return false
	
func handle_house_construction(actor, blackboard) -> bool:
	var h = blackboard.get_value("house")
	if h.resources == (10 - h.construction):
		blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.BUILDING)
		blackboard.set_value("destination", h.global_position)
		blackboard.set_value("desired_distance", 3.0)
		return true
	elif blackboard.get_value("carrying_resources") > 0:
		set_carrying("planks", 3.0, blackboard, actor)
		return true
	else:
		var source = get_closest_tree(actor.global_position)
		if source != null:
			blackboard.set_value("source", source)
			blackboard.set_value("destination", source.global_position)
			blackboard.set_value("desired_distance", 1.0)
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.CHOPPING)
			blackboard.set_value("resource_storage", h.global_position)
			return true
		else:
			#we are fcked no apples left or a bug, good luck
			return false
		
func set_carrying(attached: String, desired_distance: float, blackboard, actor):
	blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.CARRYING)
	blackboard.set_value("destination", blackboard.get_value("resource_storage"))
	blackboard.set_value("desired_distance", desired_distance)
	blackboard.set_value("attached", attached)
	actor.show_attached(attached)

func get_closest_tree(actor_pos):
	var arr = get_tree().get_nodes_in_group("trees")
	if arr.is_empty():
		return null
	else:
		var result = arr[0]
		for i in range(arr.size()):
			if actor_pos.distance_squared_to(result.global_position) > actor_pos.distance_squared_to(arr[i].global_position):
				result = arr[i]
		result.remove_from_group("trees") #so others won't take it, i guess
		return result
	
func get_closest_apple_tree(actor_pos):
	var arr = get_tree().get_nodes_in_group("apple_trees")
	if arr.is_empty():
		return null
	else:
		var result = arr[0]
		for i in range(arr.size()):
			if actor_pos.distance_squared_to(result.global_position) > actor_pos.distance_squared_to(arr[i].global_position):
				result = arr[i]
		result.remove_from_group("apple_trees") #so others won't take it, i guess
		return result

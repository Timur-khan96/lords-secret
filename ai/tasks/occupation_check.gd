extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	var curr_occup = blackboard.get_value("occupation")
	if actor.game_info.status == NpcUtility.NPC_Status.LEAVING:
		if !curr_occup == NpcUtility.OCCUPATIONS.LEAVING:
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.LEAVING)
			blackboard.set_value("destination", WorldUtility.get_random_point_outside_bounds())
		return FAILURE
	if blackboard.get_value("is_nightime"):
		if curr_occup != NpcUtility.OCCUPATIONS.CARRYING:
			if !curr_occup == NpcUtility.OCCUPATIONS.SLEEPING:
				blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.SLEEPING)
				blackboard.set_value("destination", 
				blackboard.get_value("plot").plot_game_info.center)
	elif blackboard.get_value("is_hungry"):
		if curr_occup == NpcUtility.OCCUPATIONS.CARRYING && blackboard.get_value("attached") == "planks":
			handle_house_construction(actor, blackboard, curr_occup)
		else:
			handle_hunger(actor, blackboard, curr_occup)
	elif !blackboard.get_value("house").construction_finished:
		handle_house_construction(actor, blackboard, curr_occup)
	else:
		blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
	return FAILURE
	
func handle_hunger(actor, blackboard, curr_occup):
	if blackboard.get_value("plot").food_storage == null:
		if blackboard.get_value("carrying_resources") > 0.0:
			if curr_occup != NpcUtility.OCCUPATIONS.CARRYING:
				set_carrying("apple_basket", 1.0, blackboard, actor)
		elif curr_occup != NpcUtility.OCCUPATIONS.GATHERING:
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.GATHERING)
			blackboard.set_value("resource_storage", 
			PlotUtility.get_random_point_in_polygon(
				blackboard.get_value("plot").get_corners_2D()
			))
			var source = get_closest_apple_tree(actor.global_position)
			if source:
				blackboard.set_value("source", source)
				blackboard.set_value("destination",source.global_position)
				blackboard.set_value("desired_distance", 1.0)
	else:
		var food_source = blackboard.get_value("plot").food_storage
		if blackboard.get_value("occupation") != NpcUtility.OCCUPATIONS.EATING:
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.EATING)
			blackboard.set_value("destination", food_source.global_position)
			blackboard.set_value("source", food_source)
			blackboard.set_value("desired_distance", 1.0)
	
func handle_house_construction(actor, blackboard, curr_occup):
	var h = blackboard.get_value("house")
	if abs(h.resources - (1.0 - h.construction)) < 0.000001:
		if curr_occup != NpcUtility.OCCUPATIONS.BUILDING:
			blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.BUILDING)
			blackboard.set_value("destination", h.global_position)
			blackboard.set_value("desired_distance", 3.0)
	elif blackboard.get_value("carrying_resources") > 0.0:
		if curr_occup != NpcUtility.OCCUPATIONS.CARRYING:
			set_carrying("planks", 3.0, blackboard, actor)
	elif curr_occup != NpcUtility.OCCUPATIONS.CHOPPING:
		blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.CHOPPING)
		#blackboard.set_value("resource", "wood")
		blackboard.set_value("resource_storage", h.global_position)
		var source = get_closest_tree(actor.global_position)
		if source:
			blackboard.set_value("source", source)
			blackboard.set_value("destination", source.global_position)
			blackboard.set_value("desired_distance", 1.0)
		
func set_carrying(attached: String, desired_distance: float, blackboard, actor):
	blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.CARRYING)
	blackboard.set_value("destination", blackboard.get_value("resource_storage"))
	blackboard.set_value("desired_distance", desired_distance)
	blackboard.set_value("attached", attached)
	actor.show_attached(attached)

func get_closest_tree(actor_pos):
	var result = null
	for t in get_tree().get_nodes_in_group("trees"):
		if result == null: 
			result = t
		elif actor_pos.distance_to(result.global_position) > actor_pos.distance_to(t.global_position):
			result = t
	result.remove_from_group("trees") #so others won't take it, i guess
	return result
	
func get_closest_apple_tree(actor_pos):
	var result = null
	for t in get_tree().get_nodes_in_group("apple_trees"):
		if result == null: 
			result = t
		elif actor_pos.distance_to(result.global_position) > actor_pos.distance_to(t.global_position):
			result = t
	return result

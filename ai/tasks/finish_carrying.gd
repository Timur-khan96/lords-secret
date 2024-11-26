extends ActionLeaf

var apple_basket_scene = load("res://village/apple_basket.tscn")

func tick(actor, blackboard: Blackboard):
	var res_dic = blackboard.get_value("carrying_resources")
	match res_dic.type:
		"planks":
			blackboard.get_value("house").resources += res_dic.capacity
		"apple_basket":
			var basket = apple_basket_scene.instantiate()
			actor.get_parent().get_parent().add_child(basket) #just adding it to the world
			blackboard.get_value("plot").food_storage = basket
			basket.global_position = blackboard.get_value("resource_storage")
			basket.resource = res_dic.capacity
		_:
			print("Unknown attached in finish_carrying action")
			
	actor.hide_attached(blackboard.get_value("attached"))
	blackboard.set_value("attached", null)
	blackboard.set_value("carrying_resources", null)
	blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.IDLE)
	return SUCCESS

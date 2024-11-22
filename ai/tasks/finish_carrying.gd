extends ActionLeaf

var apple_basket_scene = load("res://village/apple_basket.tscn")

func tick(actor, blackboard: Blackboard):
	match blackboard.get_value("attached"):
		"planks":
			blackboard.get_value("house").resources += blackboard.get_value("carrying_resources")
			blackboard.set_value("carrying_resources", 0.0)
		"apple_basket":
			var basket = apple_basket_scene.instantiate()
			actor.get_parent().get_parent().add_child(basket) #just adding it to the world
			blackboard.get_value("plot").food_storage = basket
			basket.global_position = blackboard.get_value("resource_storage")
			basket.resource = blackboard.get_value("carrying_resources")
			blackboard.set_value("carrying_resources", 0.0)
		_:
			print("Unknown attached in finish_carrying action")
			
	actor.hide_attached(blackboard.get_value("attached"))
	return SUCCESS

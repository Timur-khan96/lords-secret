extends Node

var villager_tree_scene = load("res://ai/trees/villager_tree.tscn")

enum NPC_Status {VISITOR, PETITIONER, VILLAGER, HIRED, ENEMY, LEAVING}
enum OCCUPATIONS {VISITING, BUILDING, CHOPPING, GATHERING, EATING, CARRYING, LEAVING, SLEEPING, ATTACKING, IDLE}

var blood_seller_game_info = null
var band = null #gets set in npcspawner

func set_as_villager(actor):
	var villager_tree = villager_tree_scene.instantiate()
	actor.add_child(villager_tree);
	actor.current_tree = villager_tree #the previous is queued in the setter
	
func set_blood_seller(blood_seller):
	blood_seller_game_info = blood_seller.game_info
	
func find_villager_by_name(full_name):
	for npc in get_tree().get_nodes_in_group("NPC"):
		if npc.game_info.status == NPC_Status.VILLAGER:
			var curr_full_name = npc.game_info.name
			if curr_full_name == full_name:
				return npc
	return null
	
func band_attack():
	for b in band.get_children():
		b.lord_attack()
		
func band_leave():
	var pos = WorldUtility.get_random_point_outside_bounds()
	for b in band.get_children():
		b.game_info.status = NPC_Status.LEAVING
		b.blackboard.set_value("destination", pos)

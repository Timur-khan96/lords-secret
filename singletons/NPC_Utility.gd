extends Node

var villager_tree_scene = load("res://ai/trees/villager_tree.tscn")

enum NPC_Status {VISITOR, PETITIONER, VILLAGER, HIRED, ENEMY, LEAVING}
enum OCCUPATIONS {VISITING, BUILDING, CHOPPING, GATHERING, EATING, CARRYING, LEAVING, SLEEPING, IDLE}

func set_as_villager(actor):
	var villager_tree = villager_tree_scene.instantiate()
	actor.add_child(villager_tree);
	actor.current_tree = villager_tree #the previous is queued in the setter
	
func find_villager_by_name(full_name):
	for npc in get_tree().get_nodes_in_group("NPC"):
		if npc.game_info.status == NPC_Status.VILLAGER:
			var curr_full_name = npc.game_info.name + " " + npc.game_info.surname
			if curr_full_name == full_name:
				return npc
	print("Such villager is not found")
	return null

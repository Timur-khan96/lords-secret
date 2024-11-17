extends Node

var villager_tree_scene = load("res://ai/trees/villager_tree.tscn")

enum NPC_Status {VISITOR, PETITIONER, VILLAGER, HIRED, ENEMY, LEAVING}

var vowels = ['a', 'e', 'i', 'o', 'u']
var consonants = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 
	'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z']
var male_name_patterns = [
	"cvc", "cvcc", "cvvc", "ccvc", "cvvcv",
	"cvcv", "cvvcvc", "cvcvc", "ccvvc", "cvcvcc",
	"cvvcc", "cvcvvc", "cvcvcv", "cvccvc", "ccvcvc"]
var female_name_patterns = [
	"vcv", "cvcc", "vcvc", "cvcv", "vccv", 
	"ccvc", "cvvc", "cvv", "cvvcv", "vccvc",
	"vcvcv", "cvcvc", "cvvvc", "vcvcc", "vcccv"]
	
var surname_patterns = [
	"cvc", "cvvc", "ccvc","cvcc", "vcvc", "cvcv","ccvcc",
	"cvvcv", "vcvvc", "cvcvcv", "cvccvc", "vcvccv", "cvvcvc",
	"cvvccv","cvcvvc" ]

func get_visitor_game_info(npc):
	var result = {
		"gender":get_gender(npc),
		"name":null,
		"surname": get_random_name(surname_patterns.pick_random()),
		"money": randi_range(100, 300),
		"family_size":1,
		"status":NPC_Status.VISITOR
	}
	var p = male_name_patterns.pick_random() if result.gender else female_name_patterns.pick_random()
	result.name = get_random_name(p)
	return result

func get_random_name(pattern: String):
	var n = ""
	for letter in pattern:
		if letter == "c":
			n += consonants.pick_random()
		elif letter == "v":
			n += vowels.pick_random()
	return n.capitalize()

func get_gender(npc):
	var result = randi_range(0, 1)
	if result:
		npc.model = load("res://villagers/male.tscn").instantiate()
		npc.add_child(npc.model)
	else:
		npc.model = load("res://villagers/female.tscn").instantiate()
		npc.add_child(npc.model)
	return result;
	
func set_as_villager(actor):
	var villager_tree = villager_tree_scene.instantiate()
	actor.add_child(villager_tree);
	actor.current_tree = villager_tree #the previous is queued in the setter

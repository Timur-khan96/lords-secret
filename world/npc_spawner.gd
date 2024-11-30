extends Node3D

var villager_scene = load("res://villagers/villager.tscn")
var has_spawned_villagers = false
var is_first_visitor = true;

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
	
var killed_people = []
var petitioner_dialogues = ["visitor_1", "visitor_2", "visitor_3", 
"visitor_4", "visitor_5", "visitor_6", "visitor_7"]
var curr_dialogues = []
var prev_dialogue = ""

func morning_spawn():
	has_spawned_villagers = true
	curr_dialogues = petitioner_dialogues.duplicate()
	var spawn_count = roundi(Global.village_reputation * 0.1)
	if spawn_count > 0:
		for i in range(spawn_count):
			var spawn_delay = randf_range(20, 40)
			spawn_villager(WorldUtility.get_random_point_outside_bounds())
			await get_tree().create_timer(spawn_delay).timeout
	else:
		spawn_baddies()
			
func spawn_villager(pos: Vector3):
	var v = villager_scene.instantiate()
	v.exploded.connect(get_parent().NPC_exploded)
	v.game_info = set_visitor_game_info(v)
	if is_first_visitor:
		is_first_visitor = false
		v.petitioner_dialogue = "visitor_1"
	else:
		v.petitioner_dialogue = set_new_petitioner_dialogue()
		
	if v.petitioner_dialogue == "visitor_2":
		v.game_info.money = 0
	elif v.petitioner_dialogue == "visitor_5_2":
		correct_gender(v.game_info.gender, NpcUtility.blood_seller_game_info.gender, v)
		v.game_info = NpcUtility.blood_seller_game_info
		v.game_info.status = NpcUtility.NPC_Status.VISITOR
	elif v.petitioner_dialogue == "visitor_7":
		set_combatant(v)
	add_child(v)
	var dest = get_parent().get_node("mansion_scene").append_mansion_queue(v)
	v.blackboard.set_value("destination", dest)
	v.global_position = pos
	
func set_combatant(npc):
	npc.is_combatant = true
	npc.model.queue_free()
	npc.model = load("res://villagers/combatant.tscn").instantiate()
	npc.game_info.gender = 1
	npc.add_child(npc.model)
	
func spawn_baddies():
	pass

func set_visitor_game_info(npc):
	var result = {
		"gender":set_gender(npc),
		"name":null,
		"surname": set_random_name(surname_patterns.pick_random()),
		"money": randi_range(100, 300),
		"family_size":1,
		"status":NpcUtility.NPC_Status.VISITOR
	}
	var p = male_name_patterns.pick_random() if result.gender else female_name_patterns.pick_random()
	result.name = set_random_name(p)
	return result
	
func set_new_petitioner_dialogue():
	if !killed_people.is_empty():
		if randf() < 0.4:
			var killed = killed_people.pick_random()
			Dialogic.VAR.killed_friend = killed
			killed_people.erase(killed)
			return "visitor_searching_dead"
	var result = prev_dialogue
	while result == prev_dialogue:
		result = curr_dialogues.pick_random()
		if result == "visitor_3":
			curr_dialogues.erase(result)
			petitioner_dialogues.erase(result)
		elif result == "visitor_5": #sells blood once per day
			curr_dialogues.erase(result)
			if NpcUtility.blood_seller_game_info != null:
				result = "visitor_5_2"
	prev_dialogue = result
	return result

func set_random_name(pattern: String):
	var n = ""
	for letter in pattern:
		if letter == "c":
			n += consonants.pick_random()
		elif letter == "v":
			n += vowels.pick_random()
	return n.capitalize()

func set_gender(npc):
	var result = randi_range(0, 1)
	if result:
		npc.model = load("res://villagers/male.tscn").instantiate()
	else:
		npc.model = load("res://villagers/female.tscn").instantiate()
	npc.add_child(npc.model)
	return result;
	
func correct_gender(g_1, g_2, npc): #for returning characters
	if g_1 == g_2: return
	else:
		npc.model.queue_free()
		if g_2:
			npc.model = load("res://villagers/male.tscn").instantiate()
		else:
			npc.model = load("res://villagers/female.tscn").instantiate()	
		npc.add_child(npc.model)
	
	

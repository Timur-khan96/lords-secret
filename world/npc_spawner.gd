extends Node3D

var villager_scene = load("res://villagers/villager.tscn")
var blood_explosion_scene = load("res://effects/blood_explosion.tscn")
var has_spawned_villagers = false

var unique_petitioner_dialogues = ["visitor_3"]

func morning_spawn():
	has_spawned_villagers = true
	var rep = Global.village_reputation
	if rep != 0:
		var spawn_count = Global.village_reputation / 10
		if spawn_count > 0:
			for i in range(spawn_count):
				var spawn_delay = randf_range(8.0, 18.0)
				spawn_villager(WorldUtility.get_random_point_outside_bounds())
				await get_tree().create_timer(spawn_delay).timeout
		else:
			spawn_baddies()
			
func spawn_villager(pos: Vector3):
	var v = villager_scene.instantiate()
	v.exploded.connect(NPC_exploded)
	var dest = get_parent().get_node("mansion_scene").append_mansion_queue(v)
	add_child(v)
	v.blackboard.set_value("destination", dest)
	v.blackboard.set_value("petitioner_dialogue", get_new_petitioner_dialogue())
	v.global_position = pos
	
func get_new_petitioner_dialogue():
	var r = randi_range(0, 3)
	if r == 0:
		if unique_petitioner_dialogues.is_empty():
			return get_new_petitioner_dialogue()
		else:
			var d = unique_petitioner_dialogues.pick_random()
			unique_petitioner_dialogues.erase(d)
			return d
	else:
		return "visitor_" + str(r)
	
func spawn_baddies():
	pass
	
func NPC_exploded(curr_NPC):
	var pos = curr_NPC.global_position
	var blood_explosion = blood_explosion_scene.instantiate()
	add_child(blood_explosion)
	blood_explosion.global_position = pos
	blood_explosion.global_position.y += 1.2
	blood_explosion.emitting = true;
	
	

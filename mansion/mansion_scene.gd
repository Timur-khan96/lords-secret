extends Node3D

var mansion_queue = []
var petitioner = null
var next_petitioner = null
#var camera;

func _ready():
	Global.mansion_scene = self
	
func append_mansion_queue(villager) -> Vector3:
	mansion_queue.append(villager)
	villager.exploded.connect(_on_petitioner_exploded) #NPC always supposed to have 
	var r = $queue_end.global_position
	$queue_end.global_position.x += 2;
	
	if mansion_queue.size() == 1:
		next_petitioner = villager
	return r
	
func pop_mansion_queue():
	if mansion_queue.is_empty() || !next_petitioner: return
	if !petitioner && next_petitioner.has_arrived:
		petitioner = mansion_queue.pop_front()
		next_petitioner = mansion_queue[0]
		
		var b = petitioner.get_node("visitor_tree/Blackboard")
		b.set_value("destination", $petition_pos.global_position)
		b.set_value("is_petitioner", true)
		open_doors()
		shift_queue()
		
func shift_queue():
	for v in mansion_queue:
		var b = v.get_node("visitor_tree/Blackboard")
		var new_pos = b.get_value("destination")
		new_pos.x -= 2
		b.set_value("destination", new_pos)
	$queue_end.global_position.x -= 2
		
func open_doors():
	$doors_body.open_doors()
	
func send_petitioner_to_plot():
	var o = petitioner.game_info.name + " " + petitioner.game_info.surname
	var plot = PlotUtility.find_plot_by_owner(o)
	var b = petitioner.get_node("visitor_tree/Blackboard")
	b.set_value("destination", plot.plot_game_info.center)
	b.set_value("is_petitioner", false)
	petitioner = null
	open_doors()
	
func send_petitioner_away():
	var point = WorldUtility.get_random_point_outside_bounds()
	var b = petitioner.get_node("visitor_tree/Blackboard")
	b.set_value("destination", point)
	b.set_value("is_petitioner", false)
	b.set_value("is_leaving", true)
	petitioner = null
	open_doors()
	
func send_queue_away(): #currently happens at dusk
	while !mansion_queue.is_empty():
		var v = mansion_queue.pop_back()
		if v != null:
			var b = v.get_node("visitor_tree/Blackboard")
			b.set_value("destination", WorldUtility.get_random_point_outside_bounds())
			b.set_value("is_leaving", true)
		$queue_end.global_position.x -= 2
		
func _on_petitioner_exploded(p):
	mansion_queue.erase(p)
	
func hide_roof():
	$mansion/roof.hide()
	$"mansion/inner roof".hide()
	
func show_roof():
	$mansion/roof.show()
	$"mansion/inner roof".show()
	

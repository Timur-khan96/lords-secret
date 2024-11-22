extends Node3D

@onready var doors = $doors_body

var mansion_queue = []
var petitioner = null
var petitioner_is_leaving = false
var next_petitioner = null
#var camera;

func _ready():
	Global.mansion_scene = self
	doors.is_mansion_door = true
	
func append_mansion_queue(villager) -> Vector3:
	mansion_queue.append(villager)
	villager.exploded.connect(_on_petitioner_exploded) #NPC always supposed to have 
	var r = $queue_end.global_position
	r.y = 0.6
	$queue_end.global_position.x += 2;
	
	if mansion_queue.size() == 1:
		next_petitioner = villager
	return r
	
func pop_mansion_queue(): #ringing a bell
	$mansion_bell.bell_ring()
	if mansion_queue.is_empty() || !next_petitioner: return
	if !petitioner && next_petitioner.has_arrived:
		petitioner = mansion_queue.pop_front()
		if !mansion_queue.is_empty():
			next_petitioner = mansion_queue[0]
		
		petitioner.blackboard.set_value("destination", $petition_pos.global_position)
		petitioner.game_info.status = NpcUtility.NPC_Status.PETITIONER
		open_doors()
		shift_queue()
		
func shift_queue():
	for v in mansion_queue:
		var new_pos = v.blackboard.get_value("destination")
		new_pos.x -= 2
		v.blackboard.set_value("destination", new_pos)
	$queue_end.global_position.x -= 2
		
func open_doors():
	doors.open_doors()
	
func send_petitioner_to_plot():
	var o = petitioner.game_info.name + " " + petitioner.game_info.surname
	var plot = PlotUtility.find_plot_by_owner(o)
	petitioner.blackboard.set_value("plot", plot)
	petitioner.blackboard.set_value("destination", plot.plot_game_info.center)
	petitioner.game_info.status = NpcUtility.NPC_Status.VILLAGER
	petitioner_is_leaving = true
	open_doors()
	
func send_petitioner_away():
	var point = WorldUtility.get_random_point_outside_bounds()
	petitioner.blackboard.set_value("destination", point)
	petitioner.game_info.status = NpcUtility.NPC_Status.LEAVING
	petitioner_is_leaving = true
	open_doors()
	
func send_queue_away(): #currently happens at dusk
	while !mansion_queue.is_empty():
		var v = mansion_queue.pop_back()
		if v != null:
			v.blackboard.set_value("destination", WorldUtility.get_random_point_outside_bounds())
			v.game_info.status = NpcUtility.NPC_Status.LEAVING
		$queue_end.global_position.x -= 2
		
func _on_petitioner_exploded(p):
	mansion_queue.erase(p)
	
func hide_roof():
	$mansion/roof.hide()
	$"mansion/inner roof".hide()
	
func show_roof():
	$mansion/roof.show()
	$"mansion/inner roof".show()
	

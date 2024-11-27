extends Node3D

@onready var doors = $doors_body

var mansion_queue = []
var petitioner = null #current petitioner
var petitioner_is_leaving = false #to nullify petitioner once doors are closed

func _ready():
	Global.mansion_scene = self
	
func append_mansion_queue(villager) -> Vector3:
	mansion_queue.append(villager)
	villager.exploded.connect(_on_villager_exploded)
	var new_pos = $queue_start.global_position
	new_pos.x += (mansion_queue.size() - 1) * 2
	new_pos.y = 0.6
	return new_pos
	
func pop_mansion_queue(): #ringing a bell
	$mansion_bell.bell_ring()
	if mansion_queue.is_empty(): return
	if petitioner != null: return
	if mansion_queue[0].blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.IDLE:
		petitioner = mansion_queue.pop_front()
		petitioner.blackboard.set_value("destination", $petition_pos.global_position)
		petitioner.game_info.status = NpcUtility.NPC_Status.PETITIONER
		open_doors()
		shift_queue()
		
func shift_queue():
	for i in range(mansion_queue.size()):
		var new_pos = $queue_start.global_position
		new_pos.x += i * 2
		new_pos.y = 0.6
		mansion_queue[i].blackboard.set_value("destination", new_pos)
		
func open_doors():
	doors.open_doors()
	
func send_petitioner_to_plot():
	var plot = PlotUtility.find_plot_by_owner(petitioner)
	petitioner.blackboard.set_value("plot", plot)
	petitioner.blackboard.set_value("destination", plot.plot_game_info.center)
	petitioner.game_info.status = NpcUtility.NPC_Status.VILLAGER
	petitioner_is_leaving = true
	open_doors()
	Global.num_of_villagers += 1
	
func send_petitioner_away():
	var point = WorldUtility.get_random_point_outside_bounds()
	petitioner.blackboard.set_value("destination", point)
	petitioner.game_info.status = NpcUtility.NPC_Status.LEAVING
	petitioner_is_leaving = true
	open_doors()
	
func send_queue_away(): #currently happens at dusk #TO CHANGE
	while !mansion_queue.is_empty():
		var v = mansion_queue.pop_back()
		if v != null:
			v.blackboard.set_value("destination", WorldUtility.get_random_point_outside_bounds())
			v.game_info.status = NpcUtility.NPC_Status.LEAVING
		
func _on_villager_exploded(p): #to check queue for changing
	var is_shifting = false
	if mansion_queue.has(p):
		is_shifting = true
		mansion_queue.erase(p)
	if mansion_queue.is_empty(): return
	var indices_to_remove = []
	for i in range(mansion_queue.size()):
		if mansion_queue[i] == null:
			indices_to_remove.append(i)
		elif mansion_queue[i].game_info.status == NpcUtility.NPC_Status.LEAVING:
			indices_to_remove.append(i)
	if !indices_to_remove.is_empty():
		is_shifting = true
		indices_to_remove.reverse() #presumably avoids arr shifting issues
		for i in indices_to_remove:
			mansion_queue.remove_at(i)
	if is_shifting:
		shift_queue()
	
func hide_roof():
	$mansion/roof.hide()
	$"mansion/inner roof".hide()
	
func show_roof():
	$mansion/roof.show()
	$"mansion/inner roof".show()
	
func _on_door_open_area_body_entered(body):
	if body is Lord:
		if body.lord_state == body.LORD_STATES.WILD:
			open_doors()

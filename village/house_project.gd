extends Node3D

var construction: int = 0
var construction_finished = false
var plot;
var door
var resources: int = 8:
	set(value):
		resources = value
		show_planks()
	
func build_iteration():
	if resources >= 1 && !construction_finished:
		construction += 1
		resources -= 1
		if construction >= 10:
			construction = 10
			construction_finished = true
			$house_1/house.transparency = 0.0
			$"house_1/floor ".transparency = 0.0
			$"house_1/roof ".transparency = 0.0
			door = load("res://village/village_door.tscn").instantiate()
			add_child(door)
			$door_open_area.area_entered.connect(_on_door_open_area_entered)
			$"house_1/roof /StaticBody3D".collision_layer = 8
			$"house_1/house ".collision_layer = 8
			$planks.queue_free()
			return true
		else:
			$house_1/house.transparency = 1.0 - float(construction * 0.1)
			$"house_1/floor ".transparency = 1.0 - float(construction * 0.1)
			$"house_1/roof ".transparency = 1.0 - float(construction * 0.1)
			return false
	else:
		print("unnecesary build iteration")
		return false
		


func _on_door_open_area_entered(area):
	if area is NPC:
		door.open_doors()
	
func show_planks():
	match resources:
		2:
			$planks/planks.show()
		4:
			$planks/planks2.show()
		6:
			$planks/planks3.show()
		8:
			$planks/planks4.show()
		10:
			$planks/planks5.show()
			
func nightime_door_open(): #called from the door when villager opens at night
	var house_owner = plot.plot_game_info.owner
	if house_owner != null:
		house_owner.blackboard.set_value("awakened", true)
	else:
		print("door was opened, but the house owner is null :(")
		
func has_owner():
	return plot.plot_game_info.owner != null
	

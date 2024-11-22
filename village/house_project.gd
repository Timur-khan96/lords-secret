extends Node3D

var construction: float = 0.0
var construction_finished = false
var plot;
var door_opened
var resources: float = 0.0:
	set(value):
		resources = snappedf(value, 0.1)
		show_planks()
	
func build_iteration():
	if resources >= 0.1 && !construction_finished:
		construction += 0.1
		if roundf(construction) >= 1:
			construction = 1.0
			construction_finished = true
			$house_1/house.transparency = 0.0
			$"house_1/floor ".transparency = 0.0
			$"house_1/roof ".transparency = 0.0
			$door_body.show()
			$door_body/CollisionShape3D.disabled = false
			$door_open_area.area_entered.connect(_on_door_open_area_entered)
			$"house_1/roof /StaticBody3D".collision_layer = 8
			$"house_1/house ".collision_layer = 8
			$planks.queue_free()
		resources -= 0.1
		$house_1/house.transparency = 1.0 - construction
		$"house_1/floor ".transparency = 1.0 - construction
		$"house_1/roof ".transparency = 1.0 - construction
	else:
		print("unnecesary build iteration")


func _on_door_open_area_entered(area):
	if area is NPC:
		$door_body.open_doors()
	
func show_planks():
	var tolerance = 0.05
	var snapped_value = snappedf(resources, 0.1)

	if abs(snapped_value - 0.2) < tolerance:
		$planks/planks.show()
	elif abs(snapped_value - 0.4) < tolerance:
		$planks/planks2.show()
	elif abs(snapped_value - 0.6) < tolerance:
		$planks/planks3.show()
	elif abs(snapped_value - 0.8) < tolerance:
		$planks/planks4.show()
	elif abs(snapped_value - 1.0) < tolerance:
		$planks/planks5.show()
	

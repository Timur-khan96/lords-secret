extends Node3D

@onready var model = $apple_tree
var apples = []

func _ready():
	for child in model.get_children():
		if child.name.contains("apple"):
			apples.append(child)

func gather():
	if apples.is_empty(): return true
	var a = apples.pick_random()
	a.hide()
	apples.erase(a)
	if apples.is_empty():
		remove_from_group("apple_trees")
		return true
	else:
		return false

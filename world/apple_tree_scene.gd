extends Node3D

@onready var model = $apple_tree
var apples = []
var hidden_apples = []

func _ready():
	for child in model.get_children():
		if child.name.contains("apple"):
			apples.append(child)

func gather():
	if apples.is_empty(): return true
	var a = apples.pop_back()
	a.hide()
	apples.erase(a)
	hidden_apples.append(a)
	if apples.is_empty():
		remove_from_group("apple_trees")
		return true
	else:
		return false

func _on_apple_growth_timeout():
	if hidden_apples.is_empty(): return
	var a = hidden_apples.pop_back()
	hidden_apples.erase(a)
	a.show()
	apples.append(a)
	if !is_in_group("apple_trees"):
		add_to_group("apple_trees")
	

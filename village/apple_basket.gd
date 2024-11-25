extends Node3D

var resource: int #get set in the villager_tree finished carrying function

func eat():
	resource -= 1
	if resource <= 0:
		queue_free.call_deferred()
		return true
	else:
		return false

extends Node3D

var resource #get set in the villager_tree finished carrying function

func eat():
	resource = snappedf(resource - 0.1, 0.1)
	if resource <= 0.0:
		queue_free.call_deferred()
		return true
	else:
		return false

extends Area3D

var NPC_within = []

func _on_area_entered(area):
	if area.is_in_group("NPC"):
		print("NPC entered")
		NPC_within.append(area)

func _on_area_exited(area):
	NPC_within.erase(area)

func lord_attack():
	if NPC_within.is_empty(): return
	for n in NPC_within:
		n.lord_attack()

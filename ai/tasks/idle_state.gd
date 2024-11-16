#extends Node
#
#@export var anim_player_var: StringName = &"anim_player"
#
#func _tick(_delta) -> Status:
	#var anim_player = blackboard.get_var(anim_player_var);
	#if anim_player:
		#match randi_range(0,1):
			#0:
				#anim_player.play("anim_pack_1/idle_1")
			#1:
				#anim_player.play("anim_pack_1/idle_2")
		#await anim_player.animation_finished
		#return SUCCESS
	#else:
		#print("Couldn't find anim player in idle_state")
		#return FAILURE

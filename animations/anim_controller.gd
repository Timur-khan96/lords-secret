extends Node

var anim_player = null

signal anim_finished

func play_animation(anim_name: String):
	match anim_name:
		"idle":
			if randi_range(0,1):
				anim_player.play("anim_lib_1/idle_1")
			else:
				anim_player.play("anim_lib_1/idle_2")
		"walk":
			anim_player.play("anim_lib_1/walk")
		"talk":
			var a = "anim_lib_1/talk_m" if get_parent().game_info.gender else "anim_lib_1/talk_f"
			anim_player.play(a)
		"attack":
			anim_player.play("anim_lib_1/attack")
		"carry":
			anim_player.play("anim_lib_1/carry")
		"gather":
			anim_player.play("anim_lib_1/gather")
		"eat":
			anim_player.play("anim_lib_1/eat")
		"sleep":
			anim_player.play("anim_lib_1/sleep")
		"run":
			anim_player.play("anim_lib_1/run")
		"sit":
			anim_player.play("anim_lib_1/sit")
			
				
func check_anim(anim: String) -> bool:
	if anim_player.is_playing():
		match anim:
			"walk":
				return anim_player.current_animation == "anim_lib_1/walk"
			"idle":
				return anim_player.current_animation == "anim_lib_1/idle_1" || anim_player.current_animation == "anim_lib_1/idle_2"
			"talk":
				var a = "anim_lib_1/talk_m" if get_parent().game_info.gender else "anim_lib_1/talk_f"
				return anim_player.current_animation == a
			"attack":
				return anim_player.current_animation == "anim_lib_1/attack"
			"carry":
				return anim_player.current_animation == "anim_lib_1/carry"
			"gather":
				return anim_player.current_animation == "anim_lib_1/gather"
			"eat":
				return anim_player.current_animation == "anim_lib_1/eat"
			"sleep":
				return anim_player.current_animation == "anim_lib_1/sleep"
			"run":
				return anim_player.current_animation == "anim_lib_1/run"
			"sit":
				return anim_player.current_animation == "anim_lib_1/sit"
			
	return false
	
func _on_anim_finished(_anim_name):
	anim_finished.emit()

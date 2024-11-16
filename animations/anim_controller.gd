extends Node

var anim_player = null

func play_animation(anim_name: String):
	match anim_name:
		"idle":
			if randi_range(0,1):
				anim_player.play("anim_pack_1/idle_1")
			else:
				anim_player.play("anim_pack_1/idle_2")
		"walk":
			anim_player.play("anim_pack_1/walk")
		"talk":
			var a = "anim_pack_1/talk_m" if get_parent().game_info.gender else "anim_pack_1/talk_f"
			anim_player.play(a)
				
func check_anim(anim: String) -> bool:
	if anim_player.is_playing():
		match anim:
			"walk":
				return anim_player.current_animation == "anim_pack_1/walk"
			"idle":
				return anim_player.current_animation == "anim_pack_1/idle_1" || anim_player.current_animation == "anim_pack_1/idle_2"
			"talk":
				var a = "anim_pack_1/talk_m" if get_parent().gender else "anim_pack_1/talk_f"
				return anim_player.current_animation == a
	return false

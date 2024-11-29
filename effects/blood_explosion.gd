extends GPUParticles3D

#var lord
#var delay = 0.5
#var attract_strength = 2.0
#
#func _process(delta):
	#if delay > 0:
		#delay -= delta
		#return
	#var dir = (lord.global_position - global_position).normalized()
	#process_material.direction = dir
	#global_position = dir * attract_strength
	#if global_position.distance_to(lord.global_position) == 0:
		#speed_scale = 0
	#else:
		#speed_scale = 1

func _on_finished():
	queue_free()

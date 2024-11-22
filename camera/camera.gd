extends Camera3D

var col_mask = 0xFFFFFFFF

func mouse_ray_check():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(from, to, col_mask)
	ray_query.collide_with_areas = true
	var raycast_results = space.intersect_ray(ray_query)
	
	if raycast_results: #subject of change hopefully
		#check this in starting plot, moving plot and moving plot's corner
		if WorldUtility.is_point_within_bounds(raycast_results.position):
			return raycast_results
	return {}
	
func _on_control_mode_changed(control_mode):
	match control_mode:
		0: #VILLAGE
			col_mask = 0xFFFFFFFF
		1: #PLOT, collide only with the floor, plots and corners (1, 2, 3)
			col_mask = pow(2, 1-1) + pow(2, 2-1) + pow(2, 3-1)
		2:
			col_mask = pow(2, 5-1) + pow(2, 7-1) #this does not work for some reason
	
			
func screen_center_ray_check():
	var space = get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2;
	var from = project_ray_origin(screen_center);
	var to = from + project_ray_normal(screen_center) * 8;
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true;
	query.collide_with_areas = true;
	query.set_collision_mask(80)
	return space.intersect_ray(query);
	
			

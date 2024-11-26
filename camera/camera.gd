extends Camera3D

var col_mask = 0xFFFFFFFF

func mouse_ray_check():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(from, to)
	ray_query.collide_with_areas = true
	ray_query.set_collision_mask(7)
	var raycast_results = space.intersect_ray(ray_query)
	
	if raycast_results: #subject of change hopefully
		#check this in starting plot, moving plot and moving plot's corner
		if WorldUtility.is_point_within_bounds(raycast_results.position):
			return raycast_results
	return {}
			
func screen_center_ray_check():
	var space = get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2;
	var from = project_ray_origin(screen_center);
	var to = from + project_ray_normal(screen_center) * 6;
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true;
	query.collide_with_areas = true;
	query.set_collision_mask(88)
	return space.intersect_ray(query);
	
			

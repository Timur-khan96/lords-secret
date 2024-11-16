extends Node3D

var tree_scene = load("res://world/tree_scene.tscn")
var apple_tree_scene = load("res://world/apple_tree_scene.tscn")

func initial_spawn():
	var obj_count = 60
	#int(half_world_size / 10.0)
	for i in range(obj_count):
		var pos = WorldUtility.get_random_point_inside_bounds()
		var new_obj
		match randi_range(0,1):
			0:
				new_obj = tree_scene.instantiate()
				set_tree(new_obj)
				add_child(new_obj)
				new_obj.global_position = pos
			1:
				new_obj = apple_tree_scene.instantiate()
				add_child(new_obj)
				new_obj.global_position = pos
		new_obj.rotation.y = randf_range(0, 2 * PI)
		var new_scale = randf_range(1.0, 2.0)
		new_obj.scale = Vector3(new_scale,new_scale,new_scale);
				
func set_tree(tree):
	match randi_range(0,1):
		0:
			tree.get_node("tree_1").queue_free()
		1:
			tree.get_node("tree_2").queue_free()
				
	
	
	

extends Area3D

var plot_game_info = {
	"name": null,
	"size": null,
	"owner": null,
	"price": null,
	"center": null
}
@onready var collision_points = $CollisionShape3D.shape.points
@onready var border_mesh = $border_mesh

const POS_Y = 0.6

enum PLOT_STATUS {BEGIN, EDIT, DONE}
var plot_status = PLOT_STATUS.BEGIN:
	set(value):
		plot_status = value
		if plot_status == PLOT_STATUS.EDIT:
			plot_color = Color.BLACK
			for c in $corners.get_children():
				c.get_node("CollisionShape3D").disabled = false
			
var plot_color: Color = Color.WHITE:
	set(value):
		plot_color = value
		$border_mesh.material_override.albedo_color = value
		if plot_status != PLOT_STATUS.DONE:
			for c in $corners.get_children():
				c.get_node("mesh").mesh.material.albedo_color = value

func _ready():
	border_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in $corners.get_children():
		c.plot = self
		c.moved.connect(_on_corner_moved)
		
func create_plot(corner1_pos, corner3_pos, new_owner): #make it automatically
	$corners/corner_1.global_position = corner1_pos;
	$corners/corner_3.global_position = corner3_pos
	set_corners()
	draw_borders()
	update_collision()
	
	plot_status = PLOT_STATUS.DONE
	plot_game_info = {
		"name": Global.village_name + " " + str(Global.plot_count),
		"owner": new_owner,
		"size": int(PlotUtility.get_area(get_corners_2D())),
		"price":0,
		"center": null
	}
	var p = PlotUtility.find_furthest_point_from_edges(get_corners_2D())
	plot_game_info.center = Vector3(p.x, POS_Y, p.y)

func update_position(ray_results: Dictionary): #used when made by player
	if ray_results:
		$corners/corner_3.global_position = ray_results.position
		set_corners()
		print($corners/corner_1.global_position)
		print($corners/corner_3.global_position)
		if $corners/corner_1.global_position.distance_to($corners/corner_4.global_position) > 1:
			draw_borders() 
			update_collision()
			
func set_corners(): #finishing positioning of the last corners
	$corners/corner_2.global_position = Vector3(
		$corners/corner_1.global_position.x,
		$corners/corner_1.global_position.y,
		$corners/corner_3.global_position.z
	)
	$corners/corner_4.global_position = Vector3(
		$corners/corner_3.global_position.x,
		$corners/corner_3.global_position.y,
		$corners/corner_1.global_position.z
	)
	position.y = POS_Y
	
func _on_corner_moved(corner: StaticBody3D, raycast_results: Dictionary):
	corner.global_position = raycast_results.position
	corner.global_position.y = POS_Y
	update_collision()
	draw_borders()
	corner.puttable = is_buildable() && !PlotUtility.is_concave(get_corners_2D())
		
func update_collision():
	collision_points[0] = $corners/corner_1.position
	collision_points[1] = $corners/corner_1.position
	collision_points[1].y = -1.0
	collision_points[2] = $corners/corner_2.position
	collision_points[3] = $corners/corner_2.position
	collision_points[3].y = -1.0
	collision_points[4] = $corners/corner_3.position
	collision_points[5] = $corners/corner_3.position
	collision_points[5].y = -1.0
	collision_points[6] = $corners/corner_4.position
	collision_points[7] = $corners/corner_4.position
	collision_points[7].y = -1.0
	$CollisionShape3D.shape.points = collision_points
		
func check_corner_distance(corner: StaticBody3D):
	for c in $corners.get_children():
		if c == corner: continue
		if c.global_position.distance_to(corner.global_position) < 2:
			return false
	return true
		
func is_buildable():
	var c = get_corners_2D()
	if PlotUtility.get_area(c) >= 20.0 && PlotUtility.min_edge_distance(c) >= 6.0:
		return !has_overlapping_areas()
	else:
		return false
		
func draw_borders():
	border_mesh.mesh.clear_surfaces()
	draw_line($corners/corner_1.position, $corners/corner_2.position)
	draw_line($corners/corner_2.position, $corners/corner_3.position)
	draw_line($corners/corner_3.position, $corners/corner_4.position)
	draw_line($corners/corner_4.position, $corners/corner_1.position)
	
func draw_line(pos_1: Vector3, pos_2: Vector3):
	border_mesh.mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	border_mesh.mesh.surface_add_vertex(pos_1)
	border_mesh.mesh.surface_add_vertex(pos_2)
	border_mesh.mesh.surface_end()

func _on_mouse_entered():
	if plot_status != PLOT_STATUS.BEGIN:
		plot_color = Color.WHITE

func _on_mouse_exited():
	if plot_status != PLOT_STATUS.BEGIN:
		plot_color = Color.BLACK
		
func show_plot_menu(is_selling = false):
	set_plot_info()
	Global.context_menu_opened(%plot_control)
	await get_tree().create_timer(0.5).timeout
	%accept_button.pressed.connect(_on_accept_button_pressed)
	%decline_button.pressed.connect(_on_decline_button_pressed)
	
	if is_selling:
		%accept_button.pressed.connect(_on_plot_selling_attempt)
	
func hide_plot_menu():
	Global.context_menu_closed(%plot_control)
	%accept_button.pressed.disconnect(_on_accept_button_pressed)
	%decline_button.pressed.disconnect(_on_decline_button_pressed)
	
func get_corners_2D():
	var points = []
	for c in $corners.get_children():
		points.append(Vector2(c.global_position.x, c.global_position.z))
	return points
	
func set_plot_info():
	if !plot_game_info.name:
		plot_game_info.name = Global.village_name + " " + str(Global.plot_count)
		Global.current_plot_project_name = plot_game_info.name
		%plot_name.text = plot_game_info.name
	if plot_status == PLOT_STATUS.EDIT:
		plot_game_info.size = int(PlotUtility.get_area(get_corners_2D()))
	%size_label.text = "Size: " + str(plot_game_info.size)
	if plot_game_info.owner:
		%owner_label.text = "Owner:" + plot_game_info.owner

func _on_accept_button_pressed():
	plot_game_info.name = %plot_name.text
	plot_game_info.price = int(%price_box.value)
	$plot_name_3D.text = plot_game_info.name
	if plot_status != PLOT_STATUS.DONE:
		plot_status = PLOT_STATUS.DONE
		var p = PlotUtility.find_furthest_point_from_edges(get_corners_2D())
		plot_game_info.center = Vector3(p.x, POS_Y, p.y)
		$corners.queue_free()
		
		$plot_name_3D.global_position = plot_game_info.center
		$plot_name_3D.global_position.y += 1.0
		$plot_name_3D.show()
		
		if plot_game_info.name == Global.current_plot_project_name:
			Global.plot_count += 1;
	hide_plot_menu()
	
func _on_plot_selling_attempt():
	Global.plot_selling_end(self)
	%accept_button.pressed.disconnect(_on_plot_selling_attempt)

func _on_decline_button_pressed():
	hide_plot_menu()
	if !plot_game_info.owner:
		queue_free()
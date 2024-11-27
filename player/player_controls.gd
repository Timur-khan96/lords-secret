extends Node

var plot_scene = load("res://plots/plot.tscn")

signal control_mode_changed

enum CONTROL_MODES {VILLAGE, PLOT, VAMPIRE}
var control_mode: CONTROL_MODES = CONTROL_MODES.VILLAGE:
	set(value):
		if value == CONTROL_MODES.VAMPIRE:
			if control_mode == CONTROL_MODES.PLOT:
				$UILayer.get_node("%plot_button").button_pressed = false
			hide_bottom_panel()
		else:
			show_bottom_panel()
		control_mode = value
		control_mode_changed.emit(value)

var is_selling_plot = false:
	set(value):
		is_selling_plot = value
		if value:
			$UILayer._on_plot_selling_start()
		else:
			$UILayer._on_plot_selling_end()

var corner_hovered = null
var current_corner #selected corner
var plot_hovered
var current_plot_project = null
var can_put_plot = true:
	set(value):
		can_put_plot = value
		if current_plot_project:
			if value:
				current_plot_project.plot_color = Color.GREEN
			else:
				current_plot_project.plot_color = Color.RED
				
func _ready():
	Global.player_controls = self
	$UILayer.player_controls = self
	$UILayer.plot_edit_toggled.connect(_on_plot_button_toggled)
	$UILayer.vampire_pressed.connect(_on_vampire_button_pressed)

func _input(event):
	if $UILayer.mouse_on_ui: return
	if control_mode == CONTROL_MODES.PLOT:
		handle_plot_control_mode_input(event)
	
func handle_plot_control_mode_input(event):
	if event is InputEventMouseMotion: 
		handle_mouse_motion()
		return
	if event.is_action_pressed("LMB"):
		handle_plot_edit()
	elif event.is_action_pressed("RMB"):
		if current_plot_project:
			current_plot_project.queue_free()
			current_plot_project = null
		elif current_corner:
			current_corner = null
		else:
			control_mode = CONTROL_MODES.VILLAGE
					
func handle_plot_edit():
	if current_plot_project:
		if can_put_plot:
			current_plot_project.plot_status = 1 #edit
			current_plot_project = null
	elif current_corner: 
		if current_corner.puttable:
			current_corner.is_moving = false
			current_corner = null
	else:
		var ray_results = %Camera.mouse_ray_check()
		if ray_results:
			if ray_results.collider.get_collision_layer() == 2: #this is a plot
				var c = ray_results.collider
				if c.plot_status != PlotUtility.PLOT_STATUS.BEGIN:
					handle_plot_selection(c)
			elif ray_results.collider.get_collision_layer() == 4: #this is a corner
				current_corner = ray_results.collider
				current_corner.is_moving = true
			else:
				current_plot_project = plot_scene.instantiate()
				%plots.add_child(current_plot_project)
				current_plot_project.global_position = ray_results.position
				can_put_plot = current_plot_project.is_buildable()
				
func handle_plot_selection(plot): #for clicking at existing plots
	if plot.plot_game_info.owner == null:
		plot.show_plot_menu(is_selling_plot)
	else:
		plot.show_plot_menu() #defaults to false
				
func handle_mouse_motion():
	if current_plot_project != null:
		current_plot_project.update_position(%Camera.mouse_ray_check())
		can_put_plot = current_plot_project.is_buildable()
	elif current_corner != null:
		current_corner.moved.emit(current_corner, %Camera.mouse_ray_check())
	else:
		var ray_result = %Camera.mouse_ray_check()
		if ray_result:
			var body = ray_result.collider
			match body.get_collision_layer():
				2: #plot
					if body.plot_status != PlotUtility.PLOT_STATUS.BEGIN:
						body.plot_color = Color.WHITE
						plot_hovered = body
				4: #corner
					corner_hovered = body
					corner_hovered.get_node("mesh").mesh.material.albedo_color = Color.GREEN
				_:
					if corner_hovered != null:
						corner_hovered.get_node("mesh").mesh.material.albedo_color = Color.BLACK
						corner_hovered = null
					if plot_hovered != null:
						plot_hovered.plot_color = Color.BLACK
						plot_hovered = null
			
				
func _on_ui_mouse_entered():
	%camera_base.can_pan = false
	
func _on_ui_mouse_exited():
	%camera_base.can_pan = true
	
func _on_plot_button_toggled(toggled_on):
	if toggled_on:
		control_mode = CONTROL_MODES.PLOT
	else:
		control_mode = CONTROL_MODES.VILLAGE

func _on_vampire_button_pressed():
	control_mode = CONTROL_MODES.VAMPIRE
	
func hide_bottom_panel():
	$UILayer.hide_bottom_panel()
	
func show_bottom_panel():
	$UILayer.show_bottom_panel()
	
func toggle_camera_process(toggled_on):
	%camera_base.set_process_input(toggled_on)
	%camera_base.set_process(toggled_on)
	
func lord_deactivated():
	control_mode = CONTROL_MODES.VILLAGE
	

				
			
		

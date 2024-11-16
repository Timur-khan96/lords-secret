extends Node3D

@onready var debug_label = $player_controls/UILayer.get_node("debug_label")
@onready var mansion = $mansion_scene
@onready var NPCSpawner = $NPCSpawner
@onready var OBJSpawner = $ObjectSpawner
@onready var nav_region = $nav_region
@onready var player_controls = %player_controls
@onready var UILayer = $player_controls/UILayer
@onready var camera = %Camera
@onready var lord = %lord
@onready var plots = %plots

const MAX_TIME_SCALE = 10.0
var POS_Y = WorldUtility.POS_Y
var WORLD_SIZE = WorldUtility.world_size #playable area

var time_scale = 1.0
var game_time = {}
var months = {}

var camera_original_global_pos = Vector3.ZERO

signal time_of_day_changed

var time_of_day: String = "Night":
	set(value):
		if value == time_of_day || value.is_empty(): return
		else:
			time_of_day = value
			UILayer.set_time_of_day_label(value)
			time_of_day_changed.emit(value)
			match(value):
				"Dawn":
					Dialogic.VAR.time_of_day = "morning"
					lord.is_day = true
					NPCSpawner.morning_spawn()
				"Afternoon":
					Dialogic.VAR.time_of_day = "afternoon"
				"Evening":
					Dialogic.VAR.time_of_day = "evening"
				"Dusk":
					lord.is_day = false
					mansion.send_queue_away()

func _ready():
	player_controls.control_mode_changed.connect(_on_control_mode_changed)
	UILayer.time_button_pressed.connect(_on_time_button_pressed)
	UILayer.bell_pressed.connect(_on_bell_button_pressed)
	
	game_time = WorldUtility.initial_game_time
	months = WorldUtility.months
	UILayer.set_time_and_date(game_time, months.get(game_time.month), str(int(time_scale)))
	
	set_world_bounds()
	Engine.time_scale = time_scale
	OBJSpawner.initial_spawn()
	nav_region.bake_navigation_mesh()
	
	lord._init_lord()
	lord.deactivate_lord()
	lord.deactivated.connect(transition_to_world_camera)
	#is not turning on
	#plots.create_plot(Vector3(-16.0,0.0,16.0),Vector3(-16.0,0.0,16.0),"You")
	
func _process(_delta):
	debug_label.text = "FPS " + str(float(Engine.get_frames_per_second()))
	if camera.current:
		if camera.global_position.distance_to(Vector3.ZERO) < 20:
			mansion.hide_roof()
		else:
			mansion.show_roof()
	
func set_world_bounds():
	$Floor/CollisionShape3D.shape.size.x = WORLD_SIZE * 1.5;
	$Floor/CollisionShape3D.shape.size.z = WORLD_SIZE * 1.5;
	$Floor/MeshInstance3D.mesh.size.x = WORLD_SIZE * 1.5
	$Floor/MeshInstance3D.mesh.size.z = WORLD_SIZE * 1.5
	%camera_base.bound_camera(WORLD_SIZE * 0.5)

func _on_time_button_pressed():
	time_scale += 1.0
	if time_scale > MAX_TIME_SCALE:
		time_scale = 1.0
	Engine.time_scale = time_scale
	%camera_base.update_pan_speed()

func _on_game_timer_timeout():
	game_time.minute += 1;
	if game_time.minute > 59:
		game_time.minute = 0
		game_time.hour += 1
		time_of_day = WorldUtility.set_time_of_day(game_time.hour)
		if game_time.hour > 23:
			game_time.hour = 0
			game_time.day += 1
			if game_time.day > 29:
				game_time.day = 1
				game_time.month += 1;
				if game_time.month > months.size():
					game_time.month = 1
					game_time.year += 1
	UILayer.set_time_and_date(game_time, months.get(game_time.month), str(int(time_scale)))
			
func _on_bell_button_pressed():
	mansion.pop_mansion_queue()
	
func _on_control_mode_changed(control_mode):
	match control_mode:
		player_controls.CONTROL_MODES.VILLAGE:
			hide_plots()
		player_controls.CONTROL_MODES.PLOT:
			if lord.is_active:
				lord.deactivate_lord()
			show_plots()
		player_controls.CONTROL_MODES.VAMPIRE:
			hide_plots()
			time_scale = 0.0;
			_on_time_button_pressed();
			transition_to_lord_camera()
			
func hide_plots():
	var plots_arr = plots.get_children()
	if plots_arr.is_empty(): return
	for p in plots_arr:
		if p.plot_status != p.PLOT_STATUS.DONE:
			p.queue_free()
			continue
		p.hide()
		
func show_plots():
	var plots_arr = plots.get_children()
	if plots_arr.is_empty(): return
	for p in plots_arr:
		p.show()
			
func transition_to_lord_camera():
	var tween = get_tree().create_tween()
	var c = lord.get_node("%lords_camera");
	camera_original_global_pos = camera.global_position
	tween.tween_property(camera, "global_position", c.global_position, 1.0)
	tween.finished.connect(switch_to_lord_camera)
	
func switch_to_lord_camera():
	camera.current = false;
	%camera_base.set_process_input(false)
	mansion.show_roof()
	lord.activate_lord()
	
func transition_to_world_camera():
	camera.current = true;
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", camera_original_global_pos, 1.0)
	tween.finished.connect(switch_to_world_camera)
	
func switch_to_world_camera():
	%camera_base.set_process_input(true)
	UILayer.third_person_off()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

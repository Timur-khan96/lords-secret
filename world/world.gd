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
@onready var day_night = $day_night
@onready var buildings = $buildings
@onready var border_mesh = $border_mesh

const MAX_TIME_SCALE = 10.0
var POS_Y = WorldUtility.POS_Y
var WORLD_SIZE = WorldUtility.world_size #playable area

var time_scale = 1.0
var game_time = {}
var months = {}

var camera_original_global_pos = Vector3.ZERO

var time_of_day: String = "Night":
	set(value):
		if value == time_of_day || value.is_empty(): return
		else:
			time_of_day = value
			UILayer.set_time_of_day_label(value)
			match(value):
				"Dawn":
					Dialogic.VAR.time_of_day = "morning"
					WorldUtility.is_daytime = true
					NPCSpawner.morning_spawn()
					check_villager_doors()
					$music_player.play_day_music()
				"Afternoon":
					Dialogic.VAR.time_of_day = "afternoon"
					$music_player.play_day_music()
				"Evening":
					Dialogic.VAR.time_of_day = "evening"
				"Dusk":
					Global.village_reputation += Global.num_of_villagers * 4
					WorldUtility.is_daytime = false
					mansion.send_queue_away()
					$music_player.play_night_music()
				"Night":
					$music_player.play_night_music()

func _ready():
	player_controls.control_mode_changed.connect(_on_control_mode_changed)
	UILayer.time_button_pressed.connect(_on_time_button_pressed)
	UILayer.bell_pressed.connect(_on_bell_button_pressed)
	PlotUtility.house_put.connect(_on_house_put)
	
	game_time = WorldUtility.initial_game_time
	months = WorldUtility.months
	UILayer.set_time_and_date(game_time, months.get(game_time.month), str(int(time_scale)))
	
	set_world_bounds()
	Engine.time_scale = time_scale
	OBJSpawner.initial_spawn()
	nav_region.bake_navigation_mesh()
	
	plots.create_plot(Vector3(-10.0,0.0,16.0),Vector3(32.0,0.0,-16.0),lord, "Warmhearth")
	plots.hide_plots()
	Dialogic.Styles.load_style("dialogic_style")
	
	day_night.play("day_night_cycle")
	day_night.seek(150) #5 hours, i think
	PlotUtility.buildings_node = buildings
	
	lord.lord_state = lord.LORD_STATES.DEACTIVATED
	lord.deactivated.connect(transition_to_world_camera)
	lord.wild_on.connect(player_controls.hide_bottom_panel)
	lord.wild_off.connect(player_controls.show_bottom_panel)
	
func _process(_delta):
	debug_label.text = "FPS " + str(float(Engine.get_frames_per_second()))
	if camera.current:
		if camera.global_position.distance_squared_to(Vector3.ZERO) < 20:
			mansion.hide_roof()
		else:
			mansion.show_roof()
	
func set_world_bounds():
	$Floor/CollisionShape3D.shape.size.x = WORLD_SIZE * 1.5;
	$Floor/CollisionShape3D.shape.size.z = WORLD_SIZE * 1.5;
	$Floor/MeshInstance3D.mesh.size.x = WORLD_SIZE * 1.5
	$Floor/MeshInstance3D.mesh.size.z = WORLD_SIZE * 1.5
	var half_world = WORLD_SIZE * 0.5
	%camera_base.bound_camera(half_world)
	border_mesh.mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	border_mesh.mesh.surface_add_vertex(Vector3(half_world, POS_Y, half_world))
	border_mesh.mesh.surface_add_vertex(Vector3(half_world, POS_Y, -half_world))
	
	border_mesh.mesh.surface_add_vertex(Vector3(half_world, POS_Y, -half_world))
	border_mesh.mesh.surface_add_vertex(Vector3(-half_world, POS_Y, -half_world))
	
	border_mesh.mesh.surface_add_vertex(Vector3(-half_world, POS_Y, -half_world))
	border_mesh.mesh.surface_add_vertex(Vector3(-half_world, POS_Y, half_world))
	
	border_mesh.mesh.surface_add_vertex(Vector3(-half_world, POS_Y, half_world))
	border_mesh.mesh.surface_add_vertex(Vector3(half_world, POS_Y, half_world))
	border_mesh.mesh.surface_end()

func _on_time_button_pressed():
	time_scale += 1.0
	if time_scale > MAX_TIME_SCALE:
		time_scale = 1.0
	Engine.time_scale = time_scale
	#print(str(Engine.time_scale))
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
			plots.hide_plots()
			border_mesh.hide()
		player_controls.CONTROL_MODES.PLOT:
			if lord.lord_state == lord.LORD_STATES.ACTIVATED:
				lord.lord_state = lord.LORD_STATES.DEACTIVATED
			plots.show_plots()
			border_mesh.show()
		player_controls.CONTROL_MODES.VAMPIRE:
			plots.hide_plots()
			border_mesh.hide()
			time_scale = 0.0;
			_on_time_button_pressed();
			transition_to_lord_camera()
			
func transition_to_lord_camera():
	var tween = get_tree().create_tween()
	player_controls.toggle_camera_process(false)
	var c = lord.get_node("%lords_camera");
	camera_original_global_pos = camera.global_position
	tween.tween_property(camera, "global_position", c.global_position, 1.0)
	tween.finished.connect(switch_to_lord)
	
func switch_to_lord():
	camera.current = false;
	mansion.show_roof()
	lord.lord_state = lord.LORD_STATES.ACTIVATED
	
func transition_to_world_camera():
	camera.current = true;
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", camera_original_global_pos, 1.0)
	player_controls.lord_deactivated()
	tween.finished.connect(switch_to_world_camera)
	
func switch_to_world_camera():
	player_controls.toggle_camera_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _on_house_put():
	nav_region.bake_navigation_mesh()
	
func check_villager_doors(): #morning reload
	for door in get_tree().get_nodes_in_group("villager_doors"):
		door.visited_this_night = false
		door.visitor_opened_door = false
		
func NPC_exploded(curr_NPC):
	if curr_NPC.petitioner_dialogue == "visitor_5_2":
		NpcUtility.blood_seller_game_info = null
	var pos = curr_NPC.global_position
	NPCSpawner.killed_people.append(str(curr_NPC.game_info.name + " " + curr_NPC.game_info.surname))
	var blood_explosion = load("res://effects/blood_explosion.tscn").instantiate()
	lord.add_child(blood_explosion)
	blood_explosion.global_position = pos
	blood_explosion.global_position.y += 1.2
	blood_explosion.emitting = true;

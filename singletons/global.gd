extends Node

var village_name: String = "Brightlands"
var lord_name: String = "Vlad Stoker"

var menu_opened = false;
var current_dialogue = null

var current_quest = 1;
var current_quest_count = 0
var current_quest_goal = 3;

var num_of_plots = 0 #lord plot excluded
var num_of_villagers = 0

#these are set in respective scripts
var player_controls
var mansion_scene
var lord

var village_reputation = 50
var money = 100
var blood:
	get():
		return lord.blood
		
var is_villager_opening_door: bool: #used in Dialogic at nightime door interaction
	get():
		var result = randf() < 0.5
		Dialogic.VAR.is_villager_opening_door = result #the door script gets it
		return result
		
func _process(_delta):
	if current_quest < 4:
		match current_quest:
			1:
				current_quest_count = num_of_plots
				if current_quest_count >= current_quest_goal:
					current_quest_count = 0
					current_quest += 1
			2:
				current_quest_count = num_of_villagers
				if current_quest_count >= current_quest_goal:
					current_quest_count = village_reputation
					current_quest_goal = 100
					current_quest += 1
			3:
				current_quest_count = village_reputation
				if current_quest_count >= current_quest_goal:
					current_quest += 1

func context_menu_opened(menu = null):
	menu_opened = true
	player_controls.set_process_input(false)
	if player_controls.control_mode == player_controls.CONTROL_MODES.VAMPIRE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if menu:
		menu.show()
	
func context_menu_closed(menu = null):
	menu_opened = false
	player_controls.set_process_input(true)
	if player_controls.control_mode == player_controls.CONTROL_MODES.VAMPIRE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if menu:
		menu.hide()
		
func start_dialogue(dialogue_name: String):
	current_dialogue = dialogue_name
	player_controls.hide_bottom_panel()
	player_controls.toggle_camera_process(false)
	context_menu_opened()
	Dialogic.start(dialogue_name)
	Dialogic.timeline_ended.connect(end_dialogue)
	
func end_dialogue():
	if player_controls.control_mode != player_controls.CONTROL_MODES.VAMPIRE:
		player_controls.show_bottom_panel()
		player_controls.toggle_camera_process(true)
	handle_dialogue_result()
	current_dialogue = null
	Dialogic.timeline_ended.disconnect(end_dialogue)
	context_menu_closed()
	
func handle_dialogue_result(is_leaving = false):
	if is_leaving:
		match current_dialogue:
			"visitor_1":
				village_reputation -= 1
			"visitor_2":
				village_reputation -= 3
			"visitor_searching_dead":
				village_reputation -= 5
		mansion_scene.send_petitioner_away()
	else:
		match current_dialogue:
			"visitor_buying_plot":
				mansion_scene.send_petitioner_to_plot()
		
func plot_selling(): #for giving selected plot to villagers, called from Dialogic
	player_controls.is_selling_plot = true
	
func plot_selling_end(plot): #called on plot accept button as signal
	player_controls.is_selling_plot = false
	var desired_cost = roundi(Dialogic.VAR.visitor.money * 0.5)
	var price = plot.plot_game_info.price
	if price > desired_cost:
		start_dialogue("visitor_not_buying_plot")
	else:
		plot.plot_game_info.owner = mansion_scene.petitioner
		mansion_scene.petitioner.game_info.money -= price
		money += price
		start_dialogue("visitor_buying_plot")
		
func check_current_quest():
	if current_quest_count >= current_quest_goal:
		current_quest += 1
		match current_quest:
			2:
				current_quest_count = 0
			3:
				current_quest_count = village_reputation
				current_quest_goal = 100
	
func get_current_quest_text():
	match current_quest:
		1:
			var t = "◊ Create at least three plots for newcomers (%d/%d)"
			return t % [current_quest_count, current_quest_goal]
		2:
			var t = "◊ Accept at least three new villagers (%d/%d)"
			return t % [current_quest_count, current_quest_goal]
		3:
			var t = "◊ Reach village reputation of one hundred (%d/%d)"
			return t % [village_reputation, current_quest_goal]
		_:
			return ""
	

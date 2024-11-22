extends Node

var village_name: String = "Brightlands"
var lord_name: String = "Vlad Drakula"
var village_reputation = 100.0
var money = 100
var blood = 1000:
	set(value):
		blood = value
		if blood < 1:
			blood = 0
			print("game over")
var blood_rate = 1 #how fast player looses blood
var plot_count = 1;
var current_plot_project_name #this one is to check if plot_count should be changed
var current_dialogue
#these are set in respective scripts
var player_controls
var mansion_scene
var lord

var menu_opened = false;

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
	context_menu_opened()
	Dialogic.start(dialogue_name)
	Dialogic.timeline_ended.connect(end_dialogue)
	
func end_dialogue():
	if player_controls.control_mode != player_controls.CONTROL_MODES.VAMPIRE:
		player_controls.show_bottom_panel()
	handle_dialogue_result()
	Dialogic.timeline_ended.disconnect(end_dialogue)
	context_menu_closed()
	
func handle_dialogue_result(is_leaving = false):
	if is_leaving:
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
		var dic = mansion_scene.petitioner.game_info
		var o = dic.name + " " + dic.surname
		plot.plot_game_info.owner = o
		
		dic.money -= price
		money += price
		start_dialogue("visitor_buying_plot")
		
func day_burning_on():
	blood_rate = 3;
	
func day_burning_off():
	blood_rate = 1;
	
	

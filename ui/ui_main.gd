extends CanvasLayer

signal time_button_pressed
signal bell_pressed
signal plot_edit_toggled
signal vampire_pressed

var mouse_on_ui = false;
#assigned in player_control _ready function
var player_controls;
var camera_base;

@onready var date_label = %date_label
@onready var time_button = %time_button
@onready var pause_button = %pause_button
@onready var money_label = $middle_top/TextureRect/MarginContainer/HBoxContainer/money_circle/money_label
@onready var blood_label = $middle_top/TextureRect/MarginContainer/HBoxContainer/blood_circle/blood_label
@onready var rep_label = $middle_top/TextureRect/MarginContainer/HBoxContainer/rep_circle/rep_label
@onready var village_name_edit = %village_name_edit
@onready var lord_name_edit = %lord_name_edit
@onready var quest_label = %quest_label

func _ready():
	for c in $middle_bottom/TextureRect/MarginContainer/HBoxContainer.get_children():
		c.mouse_entered.connect(_on_ui_mouse_entered)
		c.mouse_exited.connect(_on_ui_mouse_exited)
		
	for c in $top_right/PanelContainer/VBoxContainer/HBoxContainer.get_children():
		c.mouse_entered.connect(_on_ui_mouse_entered)
		c.mouse_exited.connect(_on_ui_mouse_exited)
		
	pause_button.button_pressed = true
	pause_button.disabled = true
	village_name_edit.text = Global.village_name
	lord_name_edit.text = Global.lord_name
		
func _process(_delta):
	money_label.text = str(Global.money)
	blood_label.text = str(Global.blood)
	rep_label.text = str(Global.village_reputation)
	quest_label.text = Global.get_current_quest_text()
		
func set_time_and_date(game_time: Dictionary, month: String, time_scale: String):
	date_label.text = str(game_time.day) + " " + month
	date_label.text += " " + str(game_time.year)
	time_button.text = "%02d" % game_time.hour + ":" + "%02d" % game_time.minute
	time_button.text += " x" + time_scale
	
func set_time_of_day_label(time_of_day: String):
	%time_of_day_label.text = time_of_day

func _on_ui_mouse_entered():
	mouse_on_ui = true
	player_controls._on_ui_mouse_entered()
	
func _on_ui_mouse_exited():
	mouse_on_ui = false;
	player_controls._on_ui_mouse_exited()
	
func _on_plot_selling_start():
	var c = roundi(Dialogic.VAR.visitor.money * 0.5)
	$selling_overlay/Label.text = """Select a plot or establish a new one
	desired cost: """ + str(c)
	$selling_overlay.show()
	if !%plot_button.button_pressed:
		%plot_button.button_pressed = true
	
func _on_plot_selling_end():
	$selling_overlay.hide()

func _on_time_button_pressed():
	time_button_pressed.emit()

func _on_bell_button_pressed():
	bell_pressed.emit()
	
func _on_plot_button_toggled(toggled_on):
	plot_edit_toggled.emit(toggled_on)

func _on_vampire_button_pressed():
	vampire_pressed.emit()
	
func hide_bottom_panel(): #during 3d-person and dialogues 
	$middle_bottom.hide()
	
func show_bottom_panel():
	$middle_bottom.show()


func _on_pause_button_toggled(toggled_on):
	get_tree().paused = toggled_on
	if toggled_on:
		pause_button.text = "▶"
	else:
		pause_button.text = "❚❚"

func _on_game_start_button_pressed():
	Global.village_name = village_name_edit.text
	Global.lord_name = lord_name_edit.text
	$village_name_control.hide()
	get_parent().get_node("%camera_base").process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.disabled = false
	pause_button.button_pressed = false
	await get_tree().create_timer(3).timeout
	$village_name_control.queue_free()
	$initial_message.show()
	
func _on_tutorial_button_toggled(toggled_on):
	$tutorial_panel.visible = toggled_on
	$tutorial_panel._on_game_help_button_pressed()
	pause_button.button_pressed = toggled_on

func _on_close_tutorial_button_pressed():
	%tutorial_button.button_pressed = false

func _on_initial_message_button_pressed():
	%quest_label.show()
	%vampire_button.disabled = false
	$initial_message.queue_free()

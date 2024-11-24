extends CanvasLayer

signal time_button_pressed
signal bell_pressed
signal plot_edit_toggled
signal vampire_pressed

var mouse_on_ui = false;
#assigned in player_control _ready function
var player_controls;
var camera_base;

@onready var date_label = $top_right/PanelContainer/VBoxContainer/date_label
@onready var time_button = $top_right/PanelContainer/VBoxContainer/time_button
@onready var money_label = $middle_top/TextureRect/MarginContainer/HBoxContainer/money_circle/money_label
@onready var blood_label = $middle_top/TextureRect/MarginContainer/HBoxContainer/blood_circle/blood_label
@onready var rep_label = $middle_top/TextureRect/MarginContainer/HBoxContainer/rep_circle/rep_label

func _ready():
	for c in $middle_bottom/TextureRect/MarginContainer/HBoxContainer.get_children():
		c.mouse_entered.connect(_on_ui_mouse_entered)
		c.mouse_exited.connect(_on_ui_mouse_exited)
		
	for c in $top_right/PanelContainer/VBoxContainer.get_children():
		c.mouse_entered.connect(_on_ui_mouse_entered)
		c.mouse_exited.connect(_on_ui_mouse_exited)
		
func _process(_delta):
	money_label.text = str(Global.money)
	blood_label.text = str(Global.blood)
	rep_label.text = str(Global.village_reputation)
		
func set_time_and_date(game_time: Dictionary, month: String, time_scale: String):
	date_label.text = str(game_time.day) + " " + month
	date_label.text += " " + str(game_time.year)
	time_button.text = "%02d" % game_time.hour + ":" + "%02d" % game_time.minute
	time_button.text += " x" + time_scale
	
func set_time_of_day_label(time_of_day: String):
	$top_right/PanelContainer/VBoxContainer/time_of_day_label.text = time_of_day

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

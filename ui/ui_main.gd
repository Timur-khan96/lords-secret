extends CanvasLayer

signal time_button_pressed
signal bell_pressed
signal plot_edit_pressed
signal vampire_pressed

var mouse_on_ui = false;
#assigned in player_control _ready function
var player_controls;
var camera_base;

@onready var date_label = $top_right/PanelContainer/VBoxContainer/date_label
@onready var time_button = $top_right/PanelContainer/VBoxContainer/time_button
@onready var money_label = $middle_top/PanelContainer/HBoxContainer/money_label
@onready var blood_label = $middle_top/PanelContainer/HBoxContainer/blood_label

func _ready():
	for c in $middle_bottom/PanelContainer/HBoxContainer.get_children():
		c.mouse_entered.connect(_on_ui_mouse_entered)
		c.mouse_exited.connect(_on_ui_mouse_exited)
		
	for c in $top_right/PanelContainer/VBoxContainer.get_children():
		c.mouse_entered.connect(_on_ui_mouse_entered)
		c.mouse_exited.connect(_on_ui_mouse_exited)
		
func _process(_delta):
	money_label.text = "money: " + str(Global.money)
	blood_label.text = "blood: " + str(Global.blood)
		
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
	
func _on_plot_selling_end():
	$selling_overlay.hide()

func _on_time_button_pressed():
	time_button_pressed.emit()

func _on_bell_button_pressed():
	bell_pressed.emit()
	
func _on_plot_button_pressed():
	plot_edit_pressed.emit()

func _on_vampire_button_pressed():
	vampire_pressed.emit()
	
func third_person_on():
	$middle_bottom.hide()
	
func third_person_off():
	$middle_bottom.show()
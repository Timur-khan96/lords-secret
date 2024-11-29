extends PanelContainer

var game_help_button_group = load("res://ui/tutorial/game_help_button_group.tres")
var tutorial_arr

func _ready():
	for b in game_help_button_group.get_buttons():
		b.pressed.connect(_on_game_help_button_pressed)
	var readme_string = FileAccess.open("res://README.txt", FileAccess.READ).get_as_text()
	tutorial_arr = readme_string.split("- ", false)


func _on_game_help_button_pressed():
	var b = game_help_button_group.get_pressed_button()
	if b:
		match b.name:
			"camera_controls_tutorial":
				%tutorial_text.text = tutorial_arr[1]
			"plot_edit_tutorial":
				%tutorial_text.text = tutorial_arr[2]
			"petitioner_tutorial":
				%tutorial_text.text = tutorial_arr[3]
			"vampire_tutorial":
				%tutorial_text.text = tutorial_arr[4]
			"village_tutorial":
				%tutorial_text.text = tutorial_arr[5]
	else:
		%tutorial_text.text = tutorial_arr[0]

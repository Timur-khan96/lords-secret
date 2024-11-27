extends PanelContainer

var game_help_button_group = load("res://ui/tutorial/game_help_button_group.tres")

func _ready():
	for b in game_help_button_group.get_buttons():
		b.pressed.connect(_on_game_help_button_pressed)

func _on_game_help_button_pressed():
	var b = game_help_button_group.get_pressed_button()
	if b:
		match b.name:
			"camera_controls_tutorial":
				%tutorial_text.text = "Camera controls tutorial"
			"plot_edit_tutorial":
				%tutorial_text.text = "plot edit tutorial"
			"petitioner_tutorial":
				%tutorial_text.text = "petitioner tutorial"
			"vampire_tutorial":
				%tutorial_text.text = "vampire tutorial"
			"village_tutorial":
				%tutorial_text.text = "village tutorial"
	else:
		%tutorial_text.text = "Choose a topic"

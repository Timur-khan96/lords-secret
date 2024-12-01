extends PanelContainer

@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")
@onready var voice_bus = AudioServer.get_bus_index("Voice")

func _ready():
	%music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	%sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	%voice_slider.value = db_to_linear(AudioServer.get_bus_volume_db(voice_bus))

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_esc()
		
func toggle_esc():
	var pause_button = get_parent().pause_button
	visible = !visible
	pause_button.button_pressed = visible
	pause_button.disabled = get_tree().paused
	if visible:
		Global.menu_opened()
	else:
		Global.menu_closed()
			
	
func _on_resume_button_pressed():
	toggle_esc()

func _on_exit_button_pressed():
	get_tree().quit()

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))

func _on_voice_slider_value_changed(value):
	AudioServer.set_bus_volume_db(voice_bus, linear_to_db(value))

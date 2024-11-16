extends Node3D

var plot_scene = load("res://plots/plot.tscn")

func create_plot(corner1_pos, corner2_pos, new_owner): #used for making plots automatically
	var plot = plot_scene.instantiate()
	add_child(plot)
	plot.create_plot(corner1_pos, corner2_pos, new_owner)

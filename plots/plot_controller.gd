extends Node3D

var plot_scene = load("res://plots/plot.tscn")

func create_plot(corner1_pos, corner2_pos, new_owner, plot_name): #used for making plots automatically
	var plot = plot_scene.instantiate()
	add_child(plot)
	plot.create_plot(corner1_pos, corner2_pos, new_owner, plot_name)
	
func hide_plots():
	var plots_arr = get_children()
	if plots_arr.is_empty(): return
	for p in plots_arr:
		if p.plot_status != PlotUtility.PLOT_STATUS.DONE:
			p.queue_free()
			continue
		p.hide()
		
func show_plots():
	var plots_arr = get_children()
	if plots_arr.is_empty(): return
	for p in plots_arr:
		p.show()

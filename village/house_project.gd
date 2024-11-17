extends StaticBody3D

var construction: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if construction >= 100:
		$plot_name_3D.text = "Construction finished"
	else:
		$plot_name_3D.text = "Construction: " + str(construction)


func _on_mouse_entered():
	$plot_name_3D.show()


func _on_mouse_exited():
	$plot_name_3D.hide()

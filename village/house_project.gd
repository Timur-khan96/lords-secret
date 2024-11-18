extends StaticBody3D

var construction: float = 0.0
var resources: float = 1.0 #resources needed for building
var plot;
	
func build_iteration():
	if resources >= 0.1 && construction < 1.0:
		construction += 0.1
		if construction > 1.0: construction = 1.0
		resources -= 0.1
		$house_project_1/house_project.transparency = 1.0 - construction
	else:
		print("unnecesary build iteration")

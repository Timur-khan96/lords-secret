extends StaticBody3D

var plot;

signal moved(corner: StaticBody3D, ray_results: Dictionary)

var puttable: bool:
	set(value):
		puttable = value
		if puttable:
			$mesh.mesh.material.albedo_color = Color.GREEN
		else:
			$mesh.mesh.material.albedo_color = Color.RED
#disable shape to prevent mouse raycast when moving the corner
var is_moving: bool = true: 
	set(value):
		is_moving = value
		$CollisionShape3D.disabled = value
			

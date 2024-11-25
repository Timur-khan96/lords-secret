extends Node

var world_size = 200.0
var half_world_size = world_size * 0.5
var POS_Y = 0.6 #subject of change, hopefully
var is_daytime = false:
	set(value):
		is_daytime = value
		Global.lord.is_daytime = value

var initial_game_time = {
	"minute":50,
	"hour":5,
	"day":1,
	"month":4,
	"year":1819
}
var months = {
	1:"January",
	2:"February",
	3:"March",
	4:"April",
	5:"May",
	6:"June",
	7:"July",
	8:"August",
	9:"September",
	10:"October",
	11:"November",
	12:"December"
}

func set_time_of_day(hour: int):
	match hour:
		6:
			return "Dawn"
		8:
			return "Morning"
		12:
			return "Afternoon"
		16:
			return "Evening"
		20:
			return "Dusk"
		22:
			return "Night"
	return "" #time of day won't change in the setter (world script)
	
func is_point_within_bounds(point: Vector3): #for playable area only
	return abs(point.x) <= half_world_size && abs(point.z) <= half_world_size
	
func get_random_point_outside_bounds() -> Vector3:
	var side = randi() % 4
	match side:
		0:  # Left side
			return Vector3(-half_world_size - randf_range(10, 20), 
			POS_Y, randf_range(-half_world_size, half_world_size))
		1:  # Right side
			return Vector3(half_world_size + randf_range(10, 20), 
			POS_Y, randf_range(-half_world_size, half_world_size))
		2:  # Top side
			return Vector3(randf_range(-half_world_size, half_world_size), 
			POS_Y, -half_world_size - randf_range(10, 20))
		3:  # Bottom side
			return Vector3(randf_range(-half_world_size, half_world_size), 
			POS_Y, half_world_size + randf_range(10, 20))

	return Vector3.ZERO
	
func get_random_point_inside_bounds() -> Vector3:
	var point = Vector3.ZERO
	while true:
		point.x = randf_range(-half_world_size, half_world_size)
		point.z = randf_range(-half_world_size, half_world_size)
		if point.distance_squared_to(Vector3.ZERO) >= 40: break
	point.y = POS_Y
	return point

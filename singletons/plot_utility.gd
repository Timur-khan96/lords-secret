extends Node

func find_plot_by_owner(owner_name): #owner is full name
	for p in get_tree().get_nodes_in_group("plots"):
		if p.plot_game_info.owner:
			if p.plot_game_info.owner == owner_name:
				return p

func is_concave(points) -> bool:
	var is_negative = false
	var is_positive = false

	for i in range(points.size()):
		var p0 = points[i]
		var p1 = points[(i + 1) % points.size()]
		var p2 = points[(i + 2) % points.size()]
		var cross_product = (p1 - p0).cross(p2 - p1)
		# Check the sign of the cross product
		if cross_product < 0:
			is_negative = true
		elif cross_product > 0:
			is_positive = true
		# If we have both positive and negative cross products, it's concave
		if is_negative and is_positive:
			return true
	return false  # All cross products had the same sign, so it's convex
	
func get_area(points: Array) -> float:
	var diag1 = points[2] - points[0]
	var diag2 = points[3] - points[1]

	# Lengths of diagonals
	var d1 = diag1.length()
	var d2 = diag2.length()

	# Angle between diagonals using dot product
	var angle = diag1.angle_to(diag2)

	# Calculate area
	var area = 0.5 * d1 * d2 * sin(angle)
	return abs(area)

func find_furthest_point_from_edges(points: Array) -> Vector2:
	var furthest_point = Vector2.ZERO
	var max_min_distance = 0.0

	# Define bounding box
	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y

	for p in points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
		
	# Step size for sampling (smaller steps yield better accuracy but are slower)
	var step_size = (max_x - min_x) / 20.0
		
	var x = min_x
	while x <= max_x:
		var y = min_y
		while y <= max_y:
			var test_point = Vector2(x, y)
			if Geometry2D.is_point_in_polygon(test_point, points):
			# Calculate the minimum distance from this point to any edge
				var min_distance = INF
				for i in range(points.size()):
					var p1 = points[i]
					var p2 = points[(i + 1) % points.size()]
					var distance = distance_point_to_segment(test_point, p1, p2)
					min_distance = min(min_distance, distance)

				# Update if this point has a larger minimum distance
				if min_distance > max_min_distance:
					max_min_distance = min_distance
					furthest_point = test_point
			
			y += step_size
		x += step_size

	return furthest_point
	
func distance_point_to_segment(point: Vector2, seg_a: Vector2, seg_b: Vector2) -> float:
	var seg_v = seg_b - seg_a
	var pt_v = point - seg_a
	var seg_len_sq = seg_v.length_squared()

	# Project the point onto the line segment and clamp t to [0, 1]
	var t = clamp(pt_v.dot(seg_v) / seg_len_sq, 0.0, 1.0)

	# Find the nearest point on the segment
	var nearest = seg_a + t * seg_v

	# Return the distance from the point to the nearest point on the segment
	return point.distance_to(nearest)

func min_edge_distance(points: Array) -> float:
	# Define edges as line segments between corners
	var edges = [
	[points[0], points[1]],
	[points[1], points[2]],
	[points[2], points[3]],
	[points[3], points[0]]
	]

	var min_distance = INF  # Start with a very large number

	# Check distance between each pair of opposite edges
	for i in range(edges.size()):
		var p1 = edges[i][0]
		var p2 = edges[i][1]
		var q1 = edges[(i + 2) % edges.size()][0]
		var q2 = edges[(i + 2) % edges.size()][1]

		# Check distances from points on one edge to the opposite edge
		var dist1 = distance_point_to_segment(p1, q1, q2)
		var dist2 = distance_point_to_segment(p2, q1, q2)

		# Find the smallest distance between these two edges
		var edge_distance = min(dist1, dist2)

		# Update minimum distance if this edge pair is narrower
		if edge_distance < min_distance:
			min_distance = edge_distance

	return min_distance

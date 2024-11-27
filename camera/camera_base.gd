extends Node3D

@onready var camera = %Camera

var min_bounds = Vector2.ZERO
var max_bounds = Vector2.ZERO
var viewport_size: Vector2

var can_pan:bool = true; #this one basically limits only on mouse UI elements
var pan_margin: float = 48.0
var pan_speed: float = 10.0
var adjusted_pan_speed #for adjustment based on zoom
var pan_direction = Vector3.ZERO

var can_zoom: bool = true;
var zoom_speed = 20.0
var zoom_speed_damp = 0.9
var zoom_direction = 0.0
var zoom_min = 1.0
var zoom_max = 80.0

var can_rotate:bool = true
var is_rotating:bool = false
var rotation_direction:int = 0
var rotation_speed = 2.0

@onready var lord = %lord

func _ready():
	viewport_size = get_viewport().get_visible_rect().size
	update_pan_speed()
	get_viewport().size_changed.connect(_on_screen_resized)
	
func _process(delta:float) -> void:
	camera_automatic_pan(delta);
	camera_zoom_update(delta);
	camera_rotate(delta);
	
func _input(event:InputEvent) -> void:
	if event.is_action("camera_zoom_in"): 
		zoom_direction -= 1;
		update_pan_speed()
	elif event.is_action("camera_zoom_out"): 
		zoom_direction += 1;
		update_pan_speed()
	
	if event.is_action_pressed("camera_rotate_left"): 
		rotation_direction = 1;
		is_rotating = true;
	elif event.is_action_pressed("camera_rotate_right"): 
		rotation_direction = -1;
		is_rotating = true;
	elif event.is_action_released("camera_rotate_left") || event.is_action_released("camera_rotate_right"):
		is_rotating = false;
	
func bound_camera(half_world_size):
	min_bounds = Vector2(-half_world_size, -half_world_size)
	max_bounds = Vector2(half_world_size, half_world_size)
	
func update_pan_speed():
	adjusted_pan_speed = pan_speed * (1.0 + abs(camera.position.z) * 0.1)
	adjusted_pan_speed = adjusted_pan_speed / max(Engine.time_scale, 1.0)

func camera_automatic_pan(delta: float) -> void:
	if !can_pan: return
	
	var current_mouse_position: Vector2 = get_viewport().get_mouse_position()
	pan_direction = Vector3.ZERO
	# Check for x-axis panning
	if current_mouse_position.x < pan_margin:
		pan_direction.x = -1
	elif current_mouse_position.x > viewport_size.x - pan_margin:
		pan_direction.x = 1
	# Check for y-axis panning
	if current_mouse_position.y < pan_margin:
		pan_direction.z = -1
	elif current_mouse_position.y > viewport_size.y - pan_margin:
		pan_direction.z = 1

	if pan_direction != Vector3.ZERO:
		translate(pan_direction * adjusted_pan_speed * delta)
		global_position.x = clamp(global_position.x, min_bounds.x, max_bounds.x)
		global_position.z = clamp(global_position.z, min_bounds.y, max_bounds.y)
		
func camera_zoom_update(delta:float) -> void:
	if !can_zoom: return
	var new_zoom = clamp(camera.position.z + zoom_speed * zoom_direction * (delta / Engine.time_scale), 
	zoom_min, zoom_max)
	camera.position.z = new_zoom;
	zoom_direction *= zoom_speed_damp;
	
func camera_rotate(delta:float) -> void:
	if !can_rotate || !is_rotating: return
	rotate_y(rotation_direction * rotation_speed * (delta / Engine.time_scale))
		
func _on_screen_resized():
	viewport_size = get_viewport().get_visible_rect().size
	update_pan_speed()

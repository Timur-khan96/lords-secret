extends CharacterBody3D
class_name Lord

@onready var camera = %lords_camera
@onready var pointer = $"UILayer2/3dperson/pointer"
@onready var model = $model
@onready var anim_controller = $anim_controller
@onready var nav_agent = $nav_agent
@onready var blood_timer = $blood_timer

signal deactivated
signal wild_on
signal wild_off

enum LORD_STATES {ACTIVATED, DEACTIVATED, WILD}
var wild_victim = null
var wild_victim_pos = Vector3.ZERO
var lord_state: LORD_STATES:
	set(value):
		match value:
			LORD_STATES.ACTIVATED:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				set_process_input(true)
				%lords_camera.current = true
				$danger_area/CollisionShape3D.disabled = false
				$UILayer2.show()
			LORD_STATES.DEACTIVATED:
				if lord_state == LORD_STATES.ACTIVATED:
					deactivate_lord()
			LORD_STATES.WILD:
				if lord_state == LORD_STATES.ACTIVATED:
					deactivate_lord() #deactivates danger_area
				$danger_area/CollisionShape3D.disabled = false
				wild_on.emit()
				if Global.current_dialogue:
					Dialogic.end_timeline()
		lord_state = value

var mouse_sens = 0.5
var interactable = null;

var speed = 5.0
var blood = 100
var is_burning = false:
	set(value):
		is_burning = value
		if value:
			blood_timer.wait_time = 2
		else:
			blood_timer.wait_time = 12
			
var is_daytime = false:
	set(value):
		is_daytime = value
		if !value:
			is_burning = false
			$day_burning.emitting = false

func _ready():
	anim_controller.anim_player = model.get_node("AnimationPlayer")
	Global.lord = self
	nav_agent.target_reached.connect(_on_nav_target_reached)

func _input(event):
	if Global.menu_opened: return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x / 100 * mouse_sens)
		$camera_base.rotate_x(-event.relative.y / 100 * mouse_sens)
		$camera_base.rotation.x = clamp($camera_base.rotation.x, -1.0, 0.25)
	elif event.is_action_pressed("LMB") && interactable:
		if interactable is MansionTable:
			lord_state = LORD_STATES.DEACTIVATED
		elif interactable is NPC:
			interactable.interact()
			start_dialogue()
		else:
			interactable.interact()
	elif event.is_action_pressed("RMB") && interactable:
		if interactable.is_in_group("NPC"):
			blood += randi_range(20,30)
			$danger_area.lord_attack()
			interactable.explode()
			
func start_dialogue():
	if is_burning:
		Global.start_dialogue("lord_burning")
	elif interactable.in_danger:
		Global.start_dialogue("in_danger")
	else:
		match interactable.game_info.status:
			NpcUtility.NPC_Status.VISITOR:
				Global.start_dialogue("visitor_interaction")
			NpcUtility.NPC_Status.VILLAGER:
				Global.start_dialogue("villager_interaction")
			NpcUtility.NPC_Status.LEAVING:
				Global.start_dialogue("visitor_leaving")
				#Dialogic.timeline_ended.connect(_on_dialogue_finished)

func _physics_process(delta):
	match lord_state:
		LORD_STATES.ACTIVATED:
			handle_movement(delta);
			handle_screen_raycast();
		LORD_STATES.DEACTIVATED:
			if !anim_controller.check_anim("idle"):
				anim_controller.play_animation("idle")
		LORD_STATES.WILD:
			handle_wild_search()
			handle_navigation_movement()
				
	if is_daytime: handle_day_raycast()
	
func handle_wild_search():
	if wild_victim == null:
		wild_victim = get_wild_state_victim()
		if wild_victim == null:
			if wild_victim_pos == Vector3.ZERO:
				wild_victim_pos = WorldUtility.get_random_point_inside_bounds()
		else:
			wild_victim_pos = wild_victim.global_position
	else:
		wild_victim_pos = wild_victim.global_position
	if nav_agent.target_position != wild_victim_pos:
		nav_agent.target_position = wild_victim_pos
				
func handle_navigation_movement():
	if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	if nav_agent.is_navigation_finished():
		if !nav_agent.is_target_reached():
			wild_victim = null
			wild_victim_pos = Vector3.ZERO 
		return
	var new_pos = nav_agent.get_next_path_position()
	velocity = global_position.direction_to(new_pos) * speed
	velocity.y = 0
	look_at(global_position + velocity, Vector3.UP)
	move_and_slide()
	if !check_anim("run"):
		play_animation("run")
				
func get_wild_state_victim():
	var arr = get_tree().get_nodes_in_group("NPC")
	if arr.is_empty():
		return null
	else:
		var r = arr[0]
		var pos = global_position
		for v in arr:
			if v == r: continue
			if pos.distance_squared_to(v.global_position) < pos.distance_squared_to(r.global_position):
				r = v
		return r
	
func handle_day_raycast():
	is_burning = !$roof_check.is_colliding()
	$day_burning.emitting = is_burning
	
func handle_screen_raycast():
	var ray_result = camera.screen_center_ray_check();
	if ray_result:
		if ray_result.collider.is_in_group("interactable"):
			interactable = ray_result.collider
			pointer.texture.region.position.x = 16;
		else:
			pointer.texture.region.position.x = 0;
			interactable = null
	else:
		pointer.texture.region.position.x = 0;
		interactable = null
	
func handle_movement(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var move_anim = "walk"
	if direction:
		if Input.is_action_pressed("shift"):
			move_anim = "run"
			speed = 7.0
		else:
			speed = 5.0
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
	
	if velocity.length() > 0:
		move_and_slide()
		if !check_anim(move_anim):
			play_animation(move_anim)
	elif !check_anim("idle"):
		play_animation("idle")
		
func hit():
	blood -= randi_range(5, 10)
		
func play_animation(anim_name: String):
	anim_controller.play_animation(anim_name)
				
func check_anim(anim_name: String) -> bool:
	return anim_controller.check_anim(anim_name)
	
func deactivate_lord():
	set_process_input(false)
	%lords_camera.current = false
	$danger_area/CollisionShape3D.disabled = true
	$UILayer2.hide()
	deactivated.emit()

func _on_blood_timer_timeout():
	blood -= 1
	if blood < 1:
		blood = 0;
		if lord_state != LORD_STATES.WILD:
			lord_state = LORD_STATES.WILD
		
func _on_nav_target_reached():
	if lord_state == LORD_STATES.WILD:
		if wild_victim != null:
			wild_victim.explode()
			blood += randi_range(20,30)
			$danger_area.lord_attack()
			wild_victim = null
			lord_state = LORD_STATES.DEACTIVATED
			wild_off.emit()
		wild_victim_pos = Vector3.ZERO
		velocity = Vector3.ZERO
	else:
		print("lord's nav_agent target reached but it isn't wild, wut???????")
		

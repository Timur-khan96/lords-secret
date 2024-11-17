extends CharacterBody3D
class_name Lord

var is_active: bool = false
var mouse_sens = 0.5
var game_info = {}
var interactable = null;

var speed = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera = %lords_camera
@onready var pointer = $"UILayer2/3dperson/pointer"
@onready var model = $model
@onready var anim_controller = $anim_controller

signal deactivated

var is_day = false:
	set(value):
		is_day = value;
		$roof_check.enabled = value

func _init_lord(): #instead of ready because we turn him off aparrently
	anim_controller.anim_player = model.get_node("AnimationPlayer")
	game_info = {
		"name": Global.lord_name,
		"gender": 1
	}
	Global.lord = self

func _input(event):
	if Global.menu_opened: return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x / 100 * mouse_sens)
		$camera_base.rotate_x(-event.relative.y / 100 * mouse_sens)
		$camera_base.rotation.x = clamp($camera_base.rotation.x, -1.0, 0.25)
	elif event.is_action_pressed("LMB") && interactable:
		if interactable is MansionTable:
			deactivate_lord()
		else:
			interactable.interact()
	elif event.is_action_pressed("RMB") && interactable:
		if interactable.is_in_group("NPC"):
			Global.blood += randi_range(20,30)
			interactable.explode()
			$danger_area.lord_attack()

func _physics_process(delta):
	handle_movement(delta);
	handle_screen_raycast();
	handle_day_raycast();
	
func _process(_delta):
	if !is_active:
		if !anim_controller.check_anim("idle"):
			anim_controller.play_animation("idle")
	
func handle_day_raycast():
	if is_day && !$roof_check.is_colliding():
		Global.day_burning_on()
		$day_burning.emitting = true;
	else:
		Global.day_burning_off()
		$day_burning.emitting = false;
	
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
	if direction:
		if Input.is_action_pressed("shift"):
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
		if !check_anim("walk"):
			play_animation("walk")
	elif !check_anim("idle"):
		play_animation("idle")
		
func play_animation(anim_name: String):
	anim_controller.play_animation(anim_name)
				
func check_anim(anim_name: String) -> bool:
	return anim_controller.check_anim(anim_name)
	
func activate_lord():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_physics_process(true)
	set_process_input(true)
	%lords_camera.current = true
	$danger_area/CollisionShape3D.disabled = false
	is_active = true;
	$UILayer2.show()
	
func deactivate_lord():
	set_physics_process(false);
	set_process_input(false)
	%lords_camera.current = false
	$danger_area/CollisionShape3D.disabled = true
	is_active = false;
	$UILayer2.hide()
	deactivated.emit()

func _on_blood_timer_timeout():
	Global.blood -= Global.blood_rate

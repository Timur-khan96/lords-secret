extends Area3D
class_name NPC

@onready var nav_agent = $nav_agent
@onready var anim_controller = $anim_controller
@onready var blackboard = $Blackboard
@onready var current_tree = $visitor_tree:
	set(value):
		if current_tree != null:
			current_tree.queue_free()
			current_tree = value
			init_tree()

var game_info = {}
var velocity = Vector3.ZERO;
var model
var has_arrived = false #boolean to check if got to the destination in blackboard
var in_danger = false #this one is to reduce reputation when leaving
var speed = 2.5

signal exploded

func _ready():
	game_info = NpcUtility.get_visitor_game_info(self) #model set here
	anim_controller.anim_player = model.get_node("AnimationPlayer")
	anim_controller.anim_player.animation_finished.connect(anim_controller._on_anim_finished)
	blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.VISITING)
	blackboard.set_value("desired_distance", 1.0) #at first it is fine
	init_tree()
	
func init_tree():
	current_tree.actor = self
	current_tree.blackboard = blackboard
	
func _physics_process(delta):
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	global_position += velocity * delta
	if velocity.length() > 0:
		look_at(global_position + velocity, Vector3.UP)
		if blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.CARRYING:
			if !check_anim("carry"):
				play_animation("carry")
		elif !check_anim("walk"):
			play_animation("walk")
		
func play_animation(anim_name: String):
	anim_controller.play_animation(anim_name)
				
func check_anim(anim_name: String) -> bool:
	return anim_controller.check_anim(anim_name)

func _on_nav_agent_navigation_finished():
	velocity = Vector3.ZERO
	
func interact():
	current_tree.enabled = false
	velocity = Vector3.ZERO
	var target_position = Global.lord.global_position
	var direction = (target_position - global_position).normalized()
	direction.y = 0
	look_at(global_position + direction, Vector3.UP)
	play_animation("talk")
	match game_info.status:
		NpcUtility.NPC_Status.VISITOR:
			Global.start_dialogue("visitor_interaction")
			Dialogic.timeline_ended.connect(_on_dialogue_finished)
		NpcUtility.NPC_Status.VILLAGER:
			Global.start_dialogue("villager_interaction")
			Dialogic.timeline_ended.connect(_on_dialogue_finished)
		
func _on_dialogue_finished():
	Dialogic.timeline_ended.disconnect(_on_dialogue_finished)
	current_tree.enabled = true
	
func lord_attack():
	speed *= 2;
	in_danger = true
	game_info.status = NpcUtility.NPC_Status.LEAVING
	blackboard.set_value("destination", WorldUtility.get_random_point_outside_bounds())
	
func explode():
	if game_info.status == NpcUtility.NPC_Status.VILLAGER:
		blackboard.get_value("plot").plot_game_info.owner = null
	exploded.emit(self)
	queue_free()

func _on_hunger_timer_timeout():
	blackboard.set_value("is_hungry", true)
	
func reload_hunger_timer():
	$hunger_timer.wait_time = 240
	$hunger_timer.start()
	
func show_attached(attached: String):
	model.get_node("%" + attached).show()
	
func hide_attached(attached: String):
	model.get_node("%" + attached).hide()
	
func _on_time_of_day_changed(time_of_day):
	if game_info.status == NpcUtility.NPC_Status.VILLAGER:
		if time_of_day == "Dawn":
			blackboard.set_value("is_nightime", false)
		elif time_of_day == "Dusk":
			blackboard.set_value("is_nightime", true)

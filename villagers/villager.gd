extends Area3D

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
var speed = 2.5

signal exploded

func _ready():
	game_info = NpcUtility.get_visitor_game_info(self)
	anim_controller.anim_player = model.get_node("AnimationPlayer")
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
		if !check_anim("walk"):
			play_animation("walk")
		
func play_animation(anim_name: String):
	anim_controller.play_animation(anim_name)
				
func check_anim(anim_name: String) -> bool:
	return anim_controller.check_anim(anim_name)

func _on_nav_agent_navigation_finished():
	#here maybe add check if we reached target or not
	velocity = Vector3.ZERO
	
func interact():
	current_tree.enabled = false
	velocity = Vector3.ZERO
	look_at(Global.lord.global_position, Vector3.UP)
	play_animation("talk")
	if game_info.status == NpcUtility.NPC_Status.VISITOR:
		Global.start_dialogue("visitor_interaction")
		Dialogic.timeline_ended.connect(_on_dialogue_finished)
		
func _on_dialogue_finished():
	current_tree.enabled = true
	
func lord_attack():
	speed *= 2;
	game_info.status = NpcUtility.NPC_Status.LEAVING
	blackboard.set_value("destination", WorldUtility.get_random_point_outside_bounds())
	
func explode():
	exploded.emit(self)
	queue_free()

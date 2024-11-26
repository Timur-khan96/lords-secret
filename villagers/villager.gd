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
var in_danger = false #this one reduces reputation when leaving (+running)
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
	if velocity.length_squared() > 0:
		global_position += velocity * delta
		look_at(global_position + velocity, Vector3.UP)
		velocity = Vector3.ZERO #one step at a time, in case of any bugs
		if blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.CARRYING:
			if !check_anim("carry"):
				play_animation("carry")
		elif in_danger:
			if !check_anim("run"):
				play_animation("run")
		elif !check_anim("walk"):
			play_animation("walk")
	$occupation.text = NpcUtility.OCCUPATIONS.find_key(blackboard.get_value("occupation"))
		
func play_animation(anim_name: String):
	anim_controller.play_animation(anim_name)
				
func check_anim(anim_name: String) -> bool:
	return anim_controller.check_anim(anim_name)

func _on_nav_agent_navigation_finished():
	velocity = Vector3.ZERO
	
func interact():
	current_tree.enabled = false
	velocity = Vector3.ZERO
	var direction = (Global.lord.global_position - global_position).normalized()
	direction.y = 0
	look_at(global_position + direction, Vector3.UP)
	play_animation("talk")
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
	if blackboard.has_value("plot"):
		print("exploded, owner should be nullified")
		blackboard.get_value("plot").nullify_owner()
	exploded.emit(self)
	queue_free.call_deferred()

func _on_hunger_timer_timeout():
	blackboard.set_value("is_hungry", true)
	
func reload_hunger_timer():
	$hunger_timer.wait_time = 240
	$hunger_timer.start()
	
func show_attached(attached: String):
	model.get_node("%" + attached).show()
	
func hide_attached(attached: String):
	model.get_node("%" + attached).hide()

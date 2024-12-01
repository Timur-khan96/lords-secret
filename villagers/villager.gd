extends Area3D
class_name NPC

@onready var nav_agent = $nav_agent
@onready var anim_controller = $anim_controller
@onready var blackboard = $Blackboard
@onready var sound = $villager_sound_controller
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
var is_combatant = false #if he runs or attacks the lord
var speed = 4
var petitioner_dialogue #dialogic timeline id

signal exploded

func _ready():
	anim_controller.anim_player = model.get_node("AnimationPlayer")
	anim_controller.anim_player.animation_finished.connect(anim_controller._on_anim_finished)
	blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.VISITING)
	blackboard.set_value("destination", Vector3.ZERO) #just in case
	blackboard.set_value("desired_distance", 1.0) #at first it is fine
	blackboard.set_value("idle_animation", "idle")
	if game_info.gender:
		sound.voice_path = "res://audio/voices/male/"
	else:
		sound.voice_path = "res://audio/voices/female/"
	
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
	#$occupation.text = NpcUtility.OCCUPATIONS.find_key(blackboard.get_value("occupation"))
	
func play_voice(current_dialogue):
	sound.play_voice(current_dialogue)
	
func play_sound(curr_sound):
	sound.play_sound(curr_sound)
		
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
	
	if !WorldUtility.is_daytime:
		blackboard.set_value("awakened", true)
		
func _on_dialogue_finished():
	Dialogic.timeline_ended.disconnect(_on_dialogue_finished)
	if !in_danger && !blackboard.get_value("awakened"):
		blackboard.set_value("awakened", false)
	current_tree.enabled = true
	
func lord_attack(): #it is actually used for all fighters to start fighting
	in_danger = true
	if is_combatant:
		game_info.status = NpcUtility.NPC_Status.ENEMY
		blackboard.set_value("occupation", NpcUtility.OCCUPATIONS.ATTACKING)
		blackboard.set_value("awakened", true)
		blackboard.set_value("attack_target", Global.lord)
		blackboard.set_value("desired_distance", 3.0)
		show_attached("axe")
		play_sound("scream")
	else:
		speed = 7;
		game_info.status = NpcUtility.NPC_Status.LEAVING
		blackboard.set_value("destination", WorldUtility.get_random_point_outside_bounds())
		if blackboard.get_value("occupation") == NpcUtility.OCCUPATIONS.SLEEPING:
			if randf() < 0.5:
				blackboard.set_value("awakened", true)
			else:
				return
		play_sound("scream")
	
func explode():
	if blackboard.has_value("plot"):
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
	
func _falling_back_to_sleep():
	if !in_danger:
		blackboard.set_value("awakened", false)

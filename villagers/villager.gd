extends Area3D

var game_info = {}
var velocity = Vector3.ZERO;
var model

var has_arrived = false #boolean to check if got to the destination in blackboard

@onready var nav_agent = $nav_agent
@onready var anim_controller = $anim_controller

var SPEED = 2.5
signal exploded

func _ready():
	game_info = NpcUtility.get_visitor_game_info(self)
	anim_controller.anim_player = model.get_node("AnimationPlayer")
	
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
	print("talking with villager")
	
func lord_attack():
	SPEED *= 2;
	var b = $visitor_tree/Blackboard
	b.set_value("is_leaving", true)
	b.set_value("destination", WorldUtility.get_random_point_outside_bounds())
	
func explode():
	exploded.emit(self)
	queue_free()

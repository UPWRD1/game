extends Node
class_name JumpingState

var player : CharacterBody3D
var gravity_direction : Vector3
var gravity : float

var jump_velocity : float = 20

func _ready():
	player = get_node("../../") as CharacterBody3D
	gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector") as Vector3
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") as float

func process_state(_delta):
	pass
	
func physics_process_state(delta):
	if (player.is_on_floor()):
		player.add_velocity(-gravity_direction * jump_velocity)
	else:
		player.add_velocity(gravity_direction * gravity)
		
	if (player.velocity.y < 0):
		player.change_state(player.possible_states["Falling"])

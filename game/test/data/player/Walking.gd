extends Node
class_name WalkingState

var player : CharacterBody3D
var head : Node3D
var gravity : float
var gravity_direction : Vector3

var speed := 420

func _ready():
	player = get_node("../..") as CharacterBody3D
	head = get_node("../../head") as Node3D
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") as float
	gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector") as Vector3
	
func process_state(delta):
	pass
	
func physics_process_state(_delta):
	if (not player):
		return
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	player.add_velocity(Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3(0, 1, 0), head.rotation.y))
	
	if (!player.is_on_floor()):
		player.change_state(player.possible_states["Falling"])
	else:
		if (Input.is_action_just_pressed("move_jump")):
			player.change_state(player.possible_states["Jumping"])
	
	player.velocity *= 0.85

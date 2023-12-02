extends Node
class_name WalkingState

var player_variables

var player : CharacterBody3D
var head : Node3D
var gravity : float
var gravity_direction : Vector3

var base_speed : float
var sprint_multiplier : float

var speed : float

func _ready():
	player_variables = get_node("/root/PlayerVariables")
	
	player = player_variables.player
	head = player_variables.player.get_node("head")
	gravity = player_variables.gravity
	gravity_direction = player_variables.gravity_direction
	base_speed = player_variables.ground_speed
	sprint_multiplier = player_variables.sprint_multiplier
	speed = base_speed
	
func process_state(delta):
	pass
	
func physics_process_state(delta):
	if (not player):
		return
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	player.add_velocity(Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, head.rotation.y) * speed * delta)
	
	if (Input.is_action_pressed("move_sprint")):
		speed = base_speed * sprint_multiplier
	else:
		speed = base_speed
	
	if (!player.is_on_floor()):
		player.change_state(player.possible_states["Falling"])
	else:
		if (Input.is_action_just_pressed("move_jump")):
			player.change_state(player.possible_states["Jumping"])
	
	player.velocity *= 0.85

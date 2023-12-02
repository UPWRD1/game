extends Node
class_name JumpingState

var player_variables

var player : CharacterBody3D
var gravity_direction : Vector3
var gravity : float
var head : Node3D
var jump_velocity : float
var speed : float
var air_resistance : float

func _ready():
	player_variables = get_node("/root/PlayerVariables")
	player = player_variables.player
	gravity_direction = player_variables.gravity_direction
	gravity = player_variables.gravity
	head = player_variables.player.get_node("head")
	jump_velocity = player_variables.jump_velocity
	speed = player_variables.jumping_speed
	air_resistance = player_variables.air_resistance

func process_state(delta):
	pass
	
func physics_process_state(delta):
	if (player.is_on_floor()):
		player.add_velocity(-gravity_direction * jump_velocity)
	else:
		player.add_velocity(gravity_direction * gravity * delta)
		
	if (player.is_on_wall_only()):
		player.change_state(player.possible_states["Wall Running"])
		
	if (player.velocity.y < 0):
		player.change_state(player.possible_states["Falling"])
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	player.add_velocity(Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, head.rotation.y) * speed * delta)
	player.velocity.x *= air_resistance
	player.velocity.z *= air_resistance

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

var wall_running_angle_threshold : float
var wall_running_angle_zone : float
var walL_running_speed_threshold : float

func _ready():
	player_variables = get_node("/root/PlayerVariables")
	player = player_variables.player
	gravity_direction = player_variables.gravity_direction
	gravity = player_variables.gravity
	head = player_variables.player.get_node("head")
	jump_velocity = player_variables.jump_velocity
	speed = player_variables.jumping_speed
	air_resistance = player_variables.air_resistance
	
	wall_running_angle_threshold = player_variables.wall_running_angle_threshold
	wall_running_angle_zone = player_variables.wall_running_angle_zone
	walL_running_speed_threshold = player_variables.wall_running_speed_threshold

func process_state(delta):
	pass
	
func physics_process_state(delta):
	if (player.is_on_floor()):
		player.add_velocity(-gravity_direction * jump_velocity)
	else:
		player.add_velocity(gravity_direction * gravity * delta)
		
	if (player.is_on_wall_only()):
		var wall_zone_forward_threshold = player.get_wall_normal().rotated(player.up_direction, wall_running_angle_threshold)
		var wall_zone_backward_threshold = player.get_wall_normal().rotated(player.up_direction, -wall_running_angle_threshold)
		var player_forward_direction = Vector3.FORWARD.rotated(player.up_direction, head.rotation.y)
		var player_angle_to_wall = min(player_forward_direction.angle_to(wall_zone_forward_threshold), player_forward_direction.angle_to(wall_zone_backward_threshold))
		
		var wall_relative_speed = max(wall_zone_forward_threshold.dot(player_forward_direction * player.velocity.length()), wall_zone_backward_threshold.dot(player_forward_direction * player.velocity.length()))
		
		print(wall_relative_speed)
		
		if ((player_angle_to_wall <= wall_running_angle_zone) and \
			 wall_relative_speed >= walL_running_speed_threshold):
				player.change_state(player.possible_states["Wall Running"])
				print("Player is now wall running")
			
		
		
	if (player.velocity.y < 0):
		player.change_state(player.possible_states["Falling"])
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	player.add_velocity(Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, head.rotation.y) * speed * delta)
	player.velocity.x *= air_resistance
	player.velocity.z *= air_resistance

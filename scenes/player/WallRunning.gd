extends Node
class_name WallRunningState

var player_variables

var player : CharacterBody3D
var head : Node3D

var speed : float
var wall_running_angle_threshold : float
var wall_running_speed_threshold : float
var wall_running_max_time : float
var wall_running_gravity_multiplier : float
var stop_wall_running_angle_deviation : float

var wall_running_direction : Vector3

var jump_velocity : float

# Called when the node enters the scene tree for the first time.
func _ready():
	player_variables = get_node("/root/PlayerVariables")

	player = player_variables.player
	head = player.get_node("head")

	speed = player_variables.wall_running_speed
	wall_running_angle_threshold = player_variables.wall_running_angle_threshold
	wall_running_speed_threshold = player_variables.wall_running_speed_threshold
	wall_running_max_time = player_variables.wall_running_max_time
	wall_running_gravity_multiplier = player_variables.wall_running_gravity_multiplier
	stop_wall_running_angle_deviation = player_variables.stop_wall_running_angle_deviation
	
	jump_velocity = player_variables.jump_velocity

func process_state(_delta):
	pass

func physics_process_state(delta):
	if (!player.is_on_wall_only()):
		player.change_state(player.possible_states["Falling"])
		return
		
	var wall_normal := player.get_wall_normal()
	var player_up := player.up_direction
	var forward_wall_direction := wall_normal.cross(player_up).normalized() # Get the direction that the player should go towards if running forward
	
	var player_forward = Vector3.FORWARD.rotated(player_up, head.rotation.y)
	
	if (Input.is_action_just_pressed("move_jump")):
		player.add_velocity(wall_normal * 10 + player_up * jump_velocity + player_forward * 5)
		player.change_state(player.possible_states["Jumping"])
	
	var player_angle_to_wall = min(player_forward.angle_to(forward_wall_direction), player_forward.angle_to(-forward_wall_direction))
	
	var player_facing_direction := signf(forward_wall_direction.dot(player_forward)) # Get the direction the player is facing relative to the wall
	
	if (player_angle_to_wall > stop_wall_running_angle_deviation):
		player.change_state(player.possible_states["Falling"])
		return
	
	wall_running_direction = forward_wall_direction * player_facing_direction # Multiply the wall forward vector by 1 or -1 to move the player along the wall
	player.add_velocity(wall_running_direction * speed * delta) # Move the player
	player.velocity *= 0.9

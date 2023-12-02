extends Node

# Project variables
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") as float
var gravity_direction : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") as Vector3
var player : CharacterBody3D

# Walking variables
var ground_speed : float = 430 #Controls horizontal movement speed on ground
var friction : float = 0.85 #Controls ground friction
var sprint_multiplier : float = 1.8

# Jumping variables
var jumping_speed : float = 420 #Controls horizontal movement speed while jumping
var jump_velocity : float = 9 #Controls jump height
var air_resistance : float = 0.905 #Controls air drag

# Falling variables
var falling_speed : float = 410 #Controls horizontal movement speed while falling

# Wall running variables
var wall_running_speed : float = 400 #Controls movement speed along walls
var wall_running_angle_threshold : float = PI/2 #Controls angle relative to wall normal needed to start wall running (radians)
var wall_running_angle_zone : float = PI/8 #Controls how much the angle can deviate from wall_running_angle_threshold to start wall running (radians)
var wall_running_speed_threshold : float = 12 #Controls minimum horizontal speed needed to start wall running
var stop_wall_running_angle_deviation : float = PI/3 #Controls how far away from the wall the player can face before they stop wall running (radians)
var wall_running_max_time : float = -1  #Controls maximum time player can wall run (-1 for infinite)
var wall_running_gravity_multiplier : float = 0 #Controls downward acceleration while wall running (0 for none)

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/world/player")

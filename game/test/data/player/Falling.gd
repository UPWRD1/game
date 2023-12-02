extends Node
class_name FallingState

var gravity : float
var gravity_direction : Vector3
var player : CharacterBody3D

func _ready():
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") as float
	gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector") as Vector3
	player = get_node("../..") as CharacterBody3D

func process_state(_delta):
	pass

func physics_process_state(delta):
	if (player.is_on_floor()):
		player.change_state(player.possible_states["Walking"])
	
	player.add_velocity(gravity * gravity_direction * delta)

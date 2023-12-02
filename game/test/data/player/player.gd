extends CharacterBody3D

@onready
var possible_states := {
"Walking" = $States/Walking, 
"Jumping" = $States/Jumping,
"Falling" = $States/Falling,
"Wall Running" = $States/WallRunning}

var state_history := []
var sensitivity := 0.1
var world
var head : Node3D
@export var current_state : Node                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             

func _input(event):
	if (event is InputEventMouseMotion):
		if !world.paused:
			head.rotation_degrees.y -= event.relative.x * sensitivity
			head.rotation_degrees.x -= event.relative.y * sensitivity

func _ready():
	current_state = possible_states["Walking"]
	world = get_parent()
	head = $head

func _process(delta):
	current_state.process_state(delta)

func _physics_process(delta):
	current_state.physics_process_state(delta)
	move_and_slide()

func change_state(state):
	current_state = state
	
func add_velocity(v : Vector3):
	velocity += v

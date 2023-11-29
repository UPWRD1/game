extends CharacterBody3D


@export var sprint_enabled = true
@export var crouch_enabled = true
@export var slide_enabled = true

@export var base_speed = 12
@export var sprint_speed = 16
@export var jump_velocity = 4
@export var sensitivity = 0.1
@export var accel = 10
@export var crouch_speed = 3
@export var slide_speed = 20

var speed = base_speed
var sprinting = false
var sliding = false
var crouching = false
var wall_running = false
var camera_fov_extents = [75.0, 85.0] #index 0 is normal, index 1 is sprinting
var base_player_y_scale = 1.0
var crouch_player_y_scale = 0.75
var wall_normal
var w_runnable = false

@onready var parts = {
	"head": $head,
	"camera": $head/camera,
	"camera_animation": $head/camera/camera_animation,
	"body": $body,
	"collision": $collision,
	"timer": $Timer,
}
@onready var world = get_parent()
@onready var timer = $Timer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall = Vector3()
var direction = Vector3()

func wall_run():
	if w_runnable:		
		if Input.is_action_pressed("move_jump"):	
			if Input.is_action_pressed("move_forward"):
				if is_on_wall():
					wall_normal = get_slide_collision(0)
					get_tree().create_timer(0.2)
					velocity.y = 0
					direction = -wall_normal.get_normal() * speed

func _ready():
	world.pause.connect(_on_pause)
	world.unpause.connect(_on_unpause)
	
	parts.camera.current = true

func _process(delta):
	wall_run()
	
	if Input.is_action_pressed("move_crouch") and sprint_enabled:
		sprinting = true
		speed = sprint_speed
		parts.camera.fov = lerp(parts.camera.fov, camera_fov_extents[1], 10*delta)
	elif Input.is_action_pressed("move_sprint") and sprint_enabled:
		sliding = true
		speed = slide_speed
		sensitivity = 0
		parts.camera.fov = lerp(parts.camera.fov, camera_fov_extents[1], 10*delta)
		parts.body.scale.y = lerp(parts.body.scale.y, crouch_player_y_scale, 10*delta) #change this to starting a crouching animation or whatever
		parts.collision.scale.y = lerp(parts.collision.scale.y, crouch_player_y_scale, 10*delta)
	else:
		sprinting = false
		crouching = false
		sliding = false
		speed = base_speed
		sensitivity = 0.1
		if sprint_enabled:
			parts.camera.fov = lerp(parts.camera.fov, camera_fov_extents[0], 10*delta)
		if crouch_enabled:
			parts.body.scale.y = lerp(parts.body.scale.y, base_player_y_scale, 10*delta) #see comment on line 48
			parts.collision.scale.y = lerp(parts.collision.scale.y, base_player_y_scale, 10*delta)

func _physics_process(delta):
	wall_run()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		w_runnable = false

	if Input.is_action_pressed("move_jump"):
		if is_on_floor():
			velocity.y += jump_velocity
			w_runnable = true
			timer.start()
	
	if (Input.is_action_pressed("move_jump") and sliding) and fall:
		velocity.y += jump_velocity
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = input_dir.normalized().rotated(-parts.head.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	if is_on_floor(): #don't lerp y movement
		velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)
	
	#bob head
	if input_dir and is_on_floor():
		parts.camera_animation.play("head_bob", 0.5)
	else:
		parts.camera_animation.play("reset", 0.5)

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		if !world.paused:
			parts.head.rotation_degrees.y -= event.relative.x * sensitivity
			parts.head.rotation_degrees.x -= event.relative.y * sensitivity
			parts.head.rotation.x = clamp(parts.head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _on_pause():
	pass

func _on_unpause():
	pass

func _on_timer_timeout():
	w_runnable = false # Replace with function body.

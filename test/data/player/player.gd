extends CharacterBody3D


@export var crouch_enabled = true
@export var slide_enabled = true

@export var base_speed = 12
@export var sprint_speed = 16
@export var jump_velocity = 5
@export var sensitivity = 0.1
@export var accel = 10
@export var crouch_speed = 3
@export var slide_speed = 0
@export var wall_run_tilt_angle : float = 45.0

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

var slide_started = false  # New variable to track if slide has started

var jump_count = 0

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
var direction = Vector3()

var current_tilt_angle: float
var wallrun_angle = 15
var side = Vector3()

func wall_run(delta):
	if w_runnable and is_on_wall():
		wall_normal = get_slide_collision(0).get_normal()
		velocity.y = 0
		side = wall_normal.cross(Vector3.UP)
		jump_count = 0
		direction = -wall_normal * speed
		wall_running = true
		speed = sprint_speed
		parts.camera.fov = lerp(parts.camera.fov, camera_fov_extents[1], 10*delta)
		if not is_on_floor():
			var to_rot = 0
			if side.dot(Vector3.RIGHT) > 0:
				to_rot = wallrun_angle
			else:
				if side.dot(Vector3.LEFT) > 0:
					to_rot = -wallrun_angle
		# Set the rotation directly
			parts.head.rotation_degrees.z = lerp(parts.head.rotation_degrees.z, float(to_rot), 0.1)
			parts.head.rotation_degrees.x = lerp(parts.head.rotation_degrees.x, 0.0, 0.1)

	else:
		wall_running = false

func _reset_camera_rotation():
	parts.head.rotation_degrees.z = lerp(parts.head.rotation_degrees.z, 0.0, 0.1)

func _ready():
	world.pause.connect(_on_pause)
	world.unpause.connect(_on_unpause)
	
	parts.camera.current = true

func _process(delta):
	wall_run(delta)
	if Input.is_action_pressed("move_sprint") and slide_enabled and not wall_running:
		var slide_direction = Vector3()
		if !slide_started:
			slide_direction = Vector3(direction.x, 0, direction.z).normalized()
			slide_started = true

		sliding = true
		speed = slide_speed
		# sensitivity = 0.001
		parts.camera.fov = lerp(parts.camera.fov, camera_fov_extents[1], 10*delta)
		parts.body.scale.y = lerp(parts.body.scale.y, crouch_player_y_scale, 20*delta) #change this to starting a crouching animation or whatever
		parts.collision.scale.y = lerp(parts.collision.scale.y, crouch_player_y_scale, 20*delta)
		velocity.x += slide_direction.x * slide_speed + (velocity.x / 100)
		velocity.z += slide_direction.z * slide_speed + (velocity.y / 100)

	else:
		sprinting = false
		crouching = false
		sliding = false
		speed = base_speed
		sensitivity = 0.1


		if slide_enabled:
			parts.camera.fov = lerp(parts.camera.fov, camera_fov_extents[0], 10*delta)
		if crouch_enabled:
			parts.body.scale.y = lerp(parts.body.scale.y, base_player_y_scale, 10*delta) #see comment on line 48
			parts.collision.scale.y = lerp(parts.collision.scale.y, base_player_y_scale, 10*delta)

func _physics_process(delta):
	wall_run(delta)

	if not is_on_floor():
		velocity.y -= (gravity * 1.3) * delta
		w_runnable = true
	else:
		w_runnable = false
		jump_count = 0  # Reset jump count when the jump key is released
	
	if not is_on_wall():
		_reset_camera_rotation()  # Reset camera rotation when on floor
	if Input.is_action_just_pressed("move_jump"):
		if is_on_floor() or jump_count < 2:
			velocity.y += jump_velocity
			jump_count += 1
			timer.start()
			sliding = false
		if wall_running:
			velocity += wall_normal * speed
			velocity.y += 4
			velocity.z += 4
			jump_count = 0

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = input_dir.normalized().rotated(-parts.head.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	if is_on_floor() and not sliding:  # don't lerp y movement
		velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)
		jump_count = 0

	if wall_running:
		velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)


	# bob head
	if input_dir and is_on_floor() and not sliding:
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

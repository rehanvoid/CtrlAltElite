extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 12.0
const MOUSE_SENSITIVITY = 0.003
const FALL_LIMIT = -10.0

@onready var camera = $Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var current_speed = SPEED
	if Input.is_action_pressed("sprint"):
		current_speed = SPRINT_SPEED

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	move_and_slide()

	if global_position.y < FALL_LIMIT:
		get_tree().reload_current_scene()

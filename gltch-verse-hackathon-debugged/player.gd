
extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 12.0
const MOUSE_SENSITIVITY = 0.003
const FALL_LIMIT = -10.0
const CAMERA_MIN_PITCH = deg_to_rad(-35.0)
const CAMERA_MAX_PITCH = deg_to_rad(55.0)

@onready var camera_pivot: Node3D = $CameraPivot
@onready var visual: MeshInstance3D = $Visual


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion \
	and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		camera_pivot.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			CAMERA_MIN_PITCH,
			CAMERA_MAX_PITCH
		)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var current_speed = SPEED
	if Input.is_action_pressed("sprint"):
		current_speed = SPRINT_SPEED

	var input_dir = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
        "move_backward"
	)

	# Move relative to the camera's horizontal direction.
	var yaw = camera_pivot.global_rotation.y
	var direction = Basis(Vector3.UP, yaw) * Vector3(
		input_dir.x, 0.0, input_dir.y
	)
	direction = direction.normalized()

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	# Turn the visible character toward the direction of travel.
	if direction.length_squared() > 0.01:
		visual.rotation.y = lerp_angle(
			visual.rotation.y,
			atan2(-direction.x, -direction.z),
			min(1.0, delta * 10.0)
		)

	move_and_slide()

	if global_position.y < FALL_LIMIT:
		get_tree().reload_current_scene()

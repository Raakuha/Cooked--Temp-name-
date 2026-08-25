extends CharacterBody3D
class_name Player

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var camera: Camera3D = $FPPCamera

signal arrived_at_target

const SPEED := 5.0
const ARRIVAL := 1.0

@export var move_speed: float = 4.0
@export var mouse_sensitivity: float = 0.002

var is_moving: bool = false
var movement_enabled: bool = false
var mouse_look_enabled: bool = false


func _ready() -> void:
	navigation_agent_3d.path_desired_distance = ARRIVAL
	navigation_agent_3d.target_desired_distance = ARRIVAL
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("========================")
	print("PLAYER READY")
	print("========================")


func move_to_target(new_target: Vector3) -> void:
	print("PLAYER: ", global_position)
	print("TARGET: ", new_target)

	navigation_agent_3d.target_position = new_target
	is_moving = true


func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled

	if not enabled:
		velocity = Vector3.ZERO

	print("PLAYER MOVEMENT -> ", enabled)


func set_mouse_look_enabled(enabled: bool) -> void:
	mouse_look_enabled = enabled

	if enabled:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	print("PLAYER MOUSE LOOK -> ", enabled)


func _input(event: InputEvent) -> void:
	if not mouse_look_enabled:
		return

	if event is InputEventMouseMotion:
		print("MOUSE MASUK: ", event.relative)

		rotate_y(-event.relative.x * mouse_sensitivity)

		camera.rotation.x -= event.relative.y * mouse_sensitivity
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)


func _physics_process(_delta: float) -> void:

	# --------------------------------------------------
	# 1. Navigation / automatic movement
	# --------------------------------------------------
	if is_moving:

		if navigation_agent_3d.is_navigation_finished():
			is_moving = false

			velocity.x = 0
			velocity.z = 0

			arrived_at_target.emit()

			print("Player sampe target")

			return

		var next_position := navigation_agent_3d.get_next_path_position()

		var arah_target: Vector3 = next_position - global_position
		arah_target.y = 0
		arah_target = arah_target.normalized()

		velocity.x = SPEED * arah_target.x
		velocity.z = SPEED * arah_target.z

		move_and_slide()

		return


	# --------------------------------------------------
	# 2. Player manual movement
	# --------------------------------------------------
	if not movement_enabled:
		return

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := (
		transform.basis * Vector3(
			input_dir.x,
			0,
			input_dir.y
		)
	).normalized()

	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			move_speed
		)

		velocity.z = move_toward(
			velocity.z,
			0,
			move_speed
		)

	move_and_slide()

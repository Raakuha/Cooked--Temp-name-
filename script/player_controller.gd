class_name PlayerController
extends CharacterBody3D

@export var move_speed: float = 4.0
@export var mouse_sensitivity: float = 0.002

@onready var camera: Camera3D = $FPPCamera

var movement_enabled: bool = false
var mouse_look_enabled: bool = false


func _ready() -> void:
	print("========================")
	print("PLAYER CONTROLLER READY")
	print("========================")


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
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()

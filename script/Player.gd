extends CharacterBody3D
class_name Player

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var camera: Camera3D = $FPPCamera
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_model: Node3D = $Armature_023

signal arrived_at_target

const SPEED := 2.00
const ARRIVAL := 1.0
@export_range(
	-180.0,
	180.0,
	1.0,
	"degrees"
)
var model_y_offset: float = 0.0



@export var move_speed: float = 2.0
@export var mouse_sensitivity: float = 0.002

## Nama clip -- kosongin salah satu/dua-duanya kalau belum ada asetnya,
## placeholder-safe sama kayak sistem di Workstation.gd.
@export var walk_animation: String = "ChefAseli/walk"
@export var idle_animation: String = "ChefAseli/idle"

var is_moving: bool = false
var movement_enabled: bool = false
var mouse_look_enabled: bool = false
var target_rotation_y: float = 0.0

## Placeholder-safe: kalau animation_player kosong, clip-nya belum ada,
## atau animasi yang diminta udah lagi jalan -- diem aja, gak restart
## animasi tiap frame (yang bikin kedutan/stutter).
func _play_movement_animation(is_currently_moving: bool) -> void:
	if animation_player == null:
		return

	var target_anim: String = (
		walk_animation if is_currently_moving else idle_animation
	)

	if target_anim == "":
		return

	if not animation_player.has_animation(target_anim):
		return

	if animation_player.current_animation == target_anim:
		return

	animation_player.play(target_anim)


func _ready() -> void:
	navigation_agent_3d.path_desired_distance = ARRIVAL
	navigation_agent_3d.target_desired_distance = ARRIVAL
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("========================")
	print("PLAYER READY")
	print("========================")


func move_to_target(new_target: Vector3, new_rotation_y: float) -> void:
	print("PLAYER: ", global_position)
	print("TARGET: ", new_target)

	navigation_agent_3d.target_position = new_target
	target_rotation_y = new_rotation_y
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
			character_model.global_rotation.y = (
				target_rotation_y
				+ deg_to_rad(model_y_offset)
			)
			_play_movement_animation(false)

			arrived_at_target.emit()

			print("Player sampe target")

			return

		var next_position := navigation_agent_3d.get_next_path_position()

		var arah_target: Vector3 = next_position - global_position
		arah_target.y = 0
		arah_target = arah_target.normalized()
		_rotate_model_toward(arah_target)
		velocity.x = SPEED * arah_target.x
		velocity.z = SPEED * arah_target.z

		_play_movement_animation(true)

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
		_rotate_model_toward(direction)

		_play_movement_animation(true)
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

		_play_movement_animation(false)

	move_and_slide()
func _rotate_model_toward(direction: Vector3) -> void:
	if direction.length_squared() <= 0.0001:
		return

	character_model.look_at(
		character_model.global_position + direction,
		Vector3.UP
	)
	
	character_model.rotate_y(PI)
	character_model.rotation.x = 0.0
	character_model.rotation.z = 0.0

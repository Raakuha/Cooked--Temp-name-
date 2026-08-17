class_name CameraDirector
extends Node


enum CameraMode {
	GAMEPLAY,
	FPP,
	HORROR,
	PSYCHIATRIST
}

@onready var gameplay_camera: Camera3D = $"../../World/Camera3D"
@onready var fpp_camera: Camera3D = $"../../PlayerBaru/FPPCamera"
@onready var player_controller: PlayerController = $"../../PlayerBaru"

@onready var horror_camera: Camera3D = $"../../World/HorrorCamera"
@onready var psychiatrist_camera: Camera3D = $"../../World/PsychiatristRoom/PsychiatristCamera"


var current_mode: CameraMode = CameraMode.GAMEPLAY


func _ready() -> void:

	switch_to_gameplay()

	print("========================")
	print("CAMERA DIRECTOR READY")
	print("Gameplay Camera :", gameplay_camera)
	print("FPP Camera      :", fpp_camera)
	print("Player Controller :", player_controller)
	print("========================")


func switch_to_gameplay() -> void:

	if gameplay_camera == null:
		print("Gameplay Camera tidak ditemukan.")
		return

	gameplay_camera.make_current()

	current_mode = CameraMode.GAMEPLAY

	player_controller.set_movement_enabled(false)
	player_controller.set_mouse_look_enabled(false)

	print("CAMERA MODE -> GAMEPLAY")

func switch_to_horror() -> void:

	if horror_camera == null:
		print("Horror Camera tidak ditemukan.")
		return

	horror_camera.make_current()
	current_mode = CameraMode.HORROR

	print("CAMERA MODE -> HORROR")

func switch_to_fpp() -> void:

	if fpp_camera == null:
		print("FPP Camera tidak ditemukan.")
		return

	fpp_camera.make_current()

	current_mode = CameraMode.FPP

	player_controller.set_movement_enabled(true)
	player_controller.set_mouse_look_enabled(true)

	print("CAMERA MODE -> FPP")


func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventKey and event.pressed and not event.echo:

		if event.keycode == KEY_F:
			switch_to_fpp()

		elif event.keycode == KEY_G:
			switch_to_gameplay()


func switch_to_psychiatrist() -> void:

	if psychiatrist_camera == null:
		print("Psychiatrist Camera tidak ditemukan.")
		return

	psychiatrist_camera.make_current()

	current_mode = CameraMode.PSYCHIATRIST

	player_controller.set_movement_enabled(false)
	player_controller.set_mouse_look_enabled(false)

	print("CAMERA MODE -> PSYCHIATRIST")

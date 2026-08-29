class_name HorrorSequenceManager
extends Node

signal sequence_started
signal sequence_finished

@export var horror_camera: Camera3D
@export var horror_focus_point: Marker3D

@export var normal_hanging_meat: Node3D
@export var human_hanging_meat: Node3D

@export var reveal_zoom_distance: float = 2.0
@export var reveal_zoom_duration: float = 3.0

@onready var transition_layer: TransitionLayer = $"../../UI/TransitionLayer"


var active: bool = false


func _ready() -> void:

	if normal_hanging_meat != null:
		normal_hanging_meat.show()

	if human_hanging_meat != null:
		human_hanging_meat.hide()



func play_basement_sequence() -> void:

	if active:
		return

	active = true

	print("========================")
	print("BASEMENT HORROR SEQUENCE")
	print("SEQUENCE START")
	print("========================")

	sequence_started.emit()

	var player = $"../../PlayerBaru"

	if player != null:
		player.set_movement_enabled(false)
		player.set_mouse_look_enabled(false)

	print("HORROR TRANSITION -> FADE OUT")

	await transition_layer.fade_out(0.7)

	if horror_camera != null:
		horror_camera.make_current()
		print("CAMERA MODE -> HORROR")

	look_camera_at_focus()

	if horror_focus_point != null:
		print("HORROR CAMERA FOCUS -> ", horror_focus_point.name)


	reveal_horror_visual()

	print("HORROR TRANSITION -> FADE IN")

	await transition_layer.fade_in(0.7)

	print("PLAYER MELIHAT HORROR VISUAL")

	await get_tree().create_timer(1.0).timeout

	await zoom_out_reveal()

	print("========================")
	print("HORROR REVEAL SELESAI")
	print("========================")

	await transition_layer.fade_out(1.0)



	print("========================")
	print("BASEMENT HORROR SEQUENCE")
	print("SEQUENCE FINISHED")
	print("========================")

	active = false
	sequence_finished.emit()

func look_camera_at_focus() -> void:

	if horror_camera == null:
		print("Horror Camera tidak ditemukan.")
		return

	if horror_focus_point == null:
		print("Horror Focus Point tidak ditemukan.")
		return

	horror_camera.look_at(
		horror_focus_point.global_position,
		Vector3.UP
	)


func reveal_horror_visual() -> void:

	print("========================")
	print("HORROR VISUAL REVEALED")
	print("========================")

	if normal_hanging_meat == null:
		print("Normal Hanging Meat tidak ditemukan.")
	else:
		normal_hanging_meat.hide()
		print("NORMAL MEAT HIDDEN")

	if human_hanging_meat == null:
		print("Human Hanging Meat tidak ditemukan.")
	else:
		human_hanging_meat.show()
		print("HUMAN MEAT VISIBLE")



func zoom_out_reveal() -> void:

	if horror_camera == null:
		return

	print("========================")
	print("HORROR CAMERA ZOOM OUT")
	print("========================")

	var start_position = horror_camera.global_position

	var direction = (
		horror_camera.global_position
		- horror_focus_point.global_position
	).normalized()

	var target_position = (
		start_position
		+ direction * reveal_zoom_distance
	)

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		horror_camera,
		"global_position",
		target_position,
		reveal_zoom_duration
	)

	await tween.finished

	print("HORROR CAMERA ZOOM OUT SELESAI")

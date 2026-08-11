extends Node3D
class_name CameraController

signal transition_finished

enum CameraMode {
	TPP_NORMAL,
	FPP_INTERACTION,
	FPP_STORY,
	FPP_EXPLORATION,
	FIXED_CINEMATIC
}
@onready var gameplay_camera: Camera3D = $GameplayCamera
@export var interaction_camera_anchor: Marker3D

var is_transitioning: bool = false
var current_mode : CameraMode = CameraMode.TPP_NORMAL
var normal_camera_transform : Transform3D
var camera_tween : Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameplay_camera.make_current()
	normal_camera_transform = gameplay_camera.global_transform
	
func enter_interaction(anchor: Marker3D) -> void:
	if anchor == null:
		push_error("Interaction Camera Anchor tidak ditemukan.")
		return
	if is_transitioning:
		return
	if current_mode == CameraMode.FPP_INTERACTION:
		return
	normal_camera_transform = gameplay_camera.global_transform
	
	current_mode = CameraMode.FPP_INTERACTION
	move_camera_to(anchor.global_transform)

func exit_interaction() -> void:
	if is_transitioning:
		return
	if current_mode != CameraMode.FPP_INTERACTION:
		return

	if current_mode != CameraMode.FPP_INTERACTION:
		return

	current_mode = CameraMode.TPP_NORMAL

	move_camera_to(normal_camera_transform)


func move_camera_to(target_transform: Transform3D) -> void:
	if camera_tween != null:
		camera_tween.kill()

	is_transitioning = true

	camera_tween = create_tween()

	camera_tween.tween_property(
		gameplay_camera,
		"global_transform",
		target_transform,
		0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	camera_tween.finished.connect(
		func():
			is_transitioning = false
			transition_finished.emit()
	)

#buat test doang 
#func _unhandled_input(event: InputEvent) -> void:
	#if is_transitioning:
		#return
#
	#if event is InputEventKey and event.echo:
		#return
#
	#if event.is_action_pressed("ui_accept"):
		#if current_mode == CameraMode.TPP_NORMAL:
			#enter_interaction(interaction_camera_anchor)
		#else:
			#exit_interaction() 

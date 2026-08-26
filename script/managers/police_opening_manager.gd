class_name PoliceOpeningManager
extends Node

signal sequence_started
signal sequence_finished

@export var police_profile: PoliceProfile

@onready var camera_director: CameraDirector = $"../CameraDirector"
@onready var dialogue_manager: DialogueManager = $"../DialogueManager"
@onready var transition_layer: TransitionLayer = $"../../UI/TransitionLayer"

@onready var police_car_sequence: Node3D = $"../../World/PoliceCarSequence"
@onready var police_camera: Camera3D = $"../../World/PoliceCarSequence/PoliceCamera"

@onready var road_moving: Node3D = $"../../World/PoliceCarSequence/RoadMoving"
@onready var animation_player: AnimationPlayer = $"../../World/PoliceCarSequence/AnimationPlayer"

@onready var engine_audio: AudioStreamPlayer = $"../../World/PoliceCarSequence/Audio/EngineAudio"
@onready var road_audio: AudioStreamPlayer = $"../../World/PoliceCarSequence/Audio/RoadAudio"



var active: bool = false



func play_opening() -> void:

	if active:
		return

	active = true

	print("========================")
	print("POLICE OPENING")
	print("SEQUENCE START")
	print("========================")

	sequence_started.emit()

	police_car_sequence.show()

	await transition_layer.fade_in(1.0)

	police_camera.make_current()

	print("CAMERA MODE -> POLICE CAR")

	if animation_player != null:
		animation_player.play("CarDriving")

	if engine_audio != null:
		engine_audio.play()

	#if road_audio != null:
		#road_audio.play()


	await play_police_dialogue()

	if animation_player != null:
		animation_player.stop()

	if engine_audio != null:
		engine_audio.stop()

	#if road_audio != null:
		#road_audio.stop()

	await transition_layer.fade_out(1.0)

	police_car_sequence.hide()

	print("========================")
	print("POLICE OPENING")
	print("SEQUENCE FINISHED")
	print("========================")

	active = false

	sequence_finished.emit()


func play_police_dialogue() -> void:

	if police_profile == null:
		print("Police profile belum dipasang.")
		return

	print("========================")
	print("POLICE OPENING DIALOGUE")
	print("Jumlah dialogue :", police_profile.opening_dialogue.size())
	print("========================")

	for dialogue in police_profile.opening_dialogue:

		dialogue_manager.start_dialog(dialogue)

		await dialogue_manager.dialogue_finished

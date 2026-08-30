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

@onready var police_model: Node3D = (
	$"../../World/PoliceCarSequence/Polisi2"
)

@onready var road_moving: Node3D = $"../../World/PoliceCarSequence/RoadMoving"
@onready var animation_player: AnimationPlayer = $"../../World/PoliceCarSequence/AnimationPlayer"

@onready var engine_audio: AudioStreamPlayer = $"../../World/PoliceCarSequence/Audio/EngineAudio"
@onready var road_audio: AudioStreamPlayer = $"../../World/PoliceCarSequence/Audio/RoadAudio"



var active: bool = false

var police_animation_player: AnimationPlayer = null


func _ready() -> void:

	if police_model == null:
		print("Model polisi tidak ditemukan.")
		return

	police_animation_player = police_model.find_child(
		"AnimationPlayer",
		true,
		false
	) as AnimationPlayer

	if police_animation_player == null:

		print(
			"AnimationPlayer polisi tidak ditemukan."
		)

		return

	print(
		"AnimationPlayer polisi ditemukan."
	)




func set_police_sitting_pose() -> void:

	if police_animation_player == null:
		return

	if not police_animation_player.has_animation("Duduk"):

		print(
			"Animasi Duduk tidak ditemukan."
		)

		return

	var animation: Animation = (
		police_animation_player.get_animation("Duduk")
	)

	print(
		"Set POLISI ke pose duduk."
	)

	police_animation_player.play("Duduk")

	police_animation_player.seek(
		animation.length,
		true
	)

	police_animation_player.pause()





func play_opening() -> void:

	if active:
		return

	active = true

	print("========================")
	print("POLICE OPENING")
	print("SEQUENCE START")
	print("========================")

	transition_layer.set_black()

	sequence_started.emit()

	# =========================================
	# SIAPKAN ADEGAN MOBIL
	# =========================================

	police_car_sequence.show()

	set_police_sitting_pose()

	# =========================================
	# CAMERA
	# =========================================

	police_camera.make_current()

	print("CAMERA MODE -> POLICE CAR")

	# =========================================
	# MULAI MOBIL + SOUND
	# =========================================

	if animation_player != null:
		animation_player.play("CarDriving")

	if engine_audio != null:
		engine_audio.play()

	# =========================================
	# FADE IN
	# =========================================

	await transition_layer.fade_in(4.5)

	# =========================================
	# OPENING DIALOGUE
	# =========================================

	await play_police_dialogue()

	# =========================================
	# FADE OUT
	# MOBIL MASIH BERGERAK DI BALIK FADE
	# =========================================

	print("POLICE OPENING -> FADE OUT")

	await transition_layer.fade_out(1.0)

	# =========================================
	# LAYAR SUDAH HITAM
	# SEKARANG BARU HENTIKAN ADEGAN
	# =========================================

	if animation_player != null:
		animation_player.stop()

	if engine_audio != null:
		engine_audio.stop()

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

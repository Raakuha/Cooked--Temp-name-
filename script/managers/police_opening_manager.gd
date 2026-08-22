class_name PoliceOpeningManager
extends Node

signal sequence_started
signal sequence_finished

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

	var dialogues := [

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Mau bagaimanapun juga, setidaknya kamu memang ahli dalam bidang ini dan aku tidak akan pernah menyetujui rencana ini."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Akan aku ingatkan, restoran itu adalah milik Irjen. Beberapa bulan yang lalu sang koki utama telah meninggal dunia sehingga membuatnya tidak beroperasi dalam kurun waktu tersebut."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Rumor mengatakan kalau katanya koki tersebut meninggal dunia karena sakit jantung, melihat dari usianya yang sudah cukup tua."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Entah apa yang dipikirkan oleh Irjen, namun bagaimanapun juga dia ingin restoran itu tetap beroperasi dan selama kami mencari koki lain yang lebih layak, Irjen memilihmu sebagai koki utama."
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "......"
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Restorannya sudah selesai dirapikan dan bahkan semua bahan juga ada untuk beberapa hari, jadi kamu setelah datang ke sana kamu bisa memulai pekerjaanmu."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Dan aku akan peringati kamu agar tidak mengacau di dapur tersebut sampai membuat pelanggan kecewa. Ini adalah satu-satunya kesempatanmu untuk meringankan beban hingga kamu bisa bebas dari penjara."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Jadi aku ingin kamu untuk bisa melayani semua pelanggan sebaik mungkin. Jika kami menerima keluhan yang buruk atau pencatatan uang yang menurun secara tidak masuk akal, maka kami akan menambahkan masa penjaramu."
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "......"
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Apakah kau dengar?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Ya"
		}
	]

	for dialogue in dialogues:

		dialogue_manager.start_dialog(dialogue)

		await dialogue_manager.dialogue_finished

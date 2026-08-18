class_name PsychiatristSequenceManager
extends Node


@onready var camera_director: CameraDirector = $"../CameraDirector"
@onready var dialogue_manager: DialogueManager = $"../DialogueManager"
@onready var transition_layer: TransitionLayer = $"../../UI/TransitionLayer"

@onready var psychiatrist_room: Node3D = $"../../World/PsychiatristRoom"


var active: bool = false


func play_day_sequence(day: int) -> void:

	if active:
		return

	active = true

	print("========================")
	print("PSYCHIATRIST SEQUENCE")
	print("DAY :", day)
	print("SEQUENCE START")
	print("========================")


	# =========================================
	# AKTIFKAN RUANG PSIKIATER
	# =========================================

	psychiatrist_room.show()


	# =========================================
	# PINDAH KE KAMERA PSIKIATER
	# =========================================

	camera_director.switch_to_psychiatrist()


	# =========================================
	# LAYAR MASIH HITAM DARI DAY SUMMARY
	# =========================================

	print("PSYCHIATRIST -> FADE IN")

	await transition_layer.fade_in(0.7)


	# =========================================
	# DIALOG SESUAI DAY
	# =========================================

	match day:

		2:
			await play_day_2()

		#4:
			#await play_day_4()
#
		#6:
			#await play_day_6()

		_:
			print("Tidak ada psychiatrist sequence untuk Day ", day)


	# =========================================
	# SELESAI
	# =========================================

	print("PSYCHIATRIST -> FADE OUT")

	await transition_layer.fade_out(0.7)

	psychiatrist_room.hide()

	camera_director.switch_to_gameplay()


	print("========================")
	print("PSYCHIATRIST SEQUENCE")
	print("SEQUENCE FINISHED")
	print("========================")

	active = false


func play_day_2() -> void:

	print("========================")
	print("PSYCHIATRIST DAY 2")
	print("========================")


	var dialogues = [

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Baiklah untuk hari ini kita akan melanjutkan evaluasinya"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Untuk sekarang apakah kau tau kenapa kau ada di ruangan ini?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Mungkin iya"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Intinya kami ingin memastikan apakah kau siap kembali hidup di tengah masyarakat."
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Ada satu hal yang ingin kutanyakan"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Apa ada hal yang paling kamu sesali dalam hidup sejauh ini?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "..."
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Sepertinya.... tidak ada"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Tidak ada?... Sama sekali?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Semua sudah terjadi dan kita tidak bisa kembali lagi"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Sebuah penyesalan tidak akan mengubah apapun"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Bagaimana dengan \"Mereka\"?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Aku tidak kenal mereka"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Kalau begitu.... bagaimana dengan orang-orang terdekatmu?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Mereka tidak hadir, atau bahkan tidak ada dan itu tidak masalah"
		}
	]
	
	await play_dialogues(dialogues)

func play_dialogues(dialogues: Array) -> void:

	for dialogue in dialogues:

		print(
			"PSYCHIATRIST DIALOG -> ",
			dialogue["speaker"]
		)

		dialogue_manager.start_dialog(dialogue)

		await dialogue_manager.dialogue_finished

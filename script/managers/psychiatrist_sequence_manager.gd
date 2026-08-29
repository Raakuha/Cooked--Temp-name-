class_name PsychiatristSequenceManager
extends Node


@onready var flashback_kitchen: Node3D = $"../../World/FlashbackKitchen"
@onready var flashback_camera: Camera3D = $"../../World/FlashbackKitchen/FlashbackCamera"

@onready var flashback_music: AudioStreamPlayer = $"../../World/FlashbackKitchen/Audio/FlashbackMusic"
@onready var soup_sfx: AudioStreamPlayer = $"../../World/FlashbackKitchen/Audio/SoupCookingSFX"
@onready var kitchen_ambience: AudioStreamPlayer = $"../../World/FlashbackKitchen/Audio/KitchenAmbience"


@onready var camera_director: CameraDirector = $"../CameraDirector"
@onready var dialogue_manager: DialogueManager = $"../DialogueManager"
@onready var transition_layer: TransitionLayer = $"../../UI/TransitionLayer"

@onready var psychiatrist_room: Node3D = $"../../World/PsychiatristRoom"

@onready var memory_objects: Node3D = (
	$"../../World/PsychiatristRoom/MemoryObjects"
)

@onready var memory_apple: Node3D = (
	$"../../World/PsychiatristRoom/MemoryObjects/Apple"
)

@onready var memory_knife: Node3D = (
	$"../../World/PsychiatristRoom/MemoryObjects/Knife"
)

@onready var memory_meat: Node3D = (
	$"../../World/PsychiatristRoom/MemoryObjects/Meat"
)



@onready var day4_flashback: Node3D = (
	$"../../World/FlashbackDay4"
)

@onready var day4_flashback_camera: Camera3D = (
	$"../../World/FlashbackDay4/FlashbackCamera"
)

@onready var day4_flashback_music: AudioStreamPlayer = (
	$"../../World/FlashbackDay4/Audio/FlashbackMusic"
)

@onready var day4_kitchen_ambience: AudioStreamPlayer = (
	$"../../World/FlashbackDay4/Audio/KitchenAmbience"
)



var active: bool = false

var memory_apple_scale: Vector3
var memory_knife_scale: Vector3
var memory_meat_scale: Vector3


func _ready() -> void:

	memory_apple_scale = memory_apple.scale
	memory_knife_scale = memory_knife.scale
	memory_meat_scale = memory_meat.scale

	hide_memory_objects()

	day4_flashback.hide()



func play_day4_flashback() -> void:

	print("========================")
	print("DAY 4 FLASHBACK")
	print("FLASHBACK START")
	print("========================")

	await transition_layer.fade_out(0.7)

	day4_flashback.show()

	day4_flashback_camera.make_current()

	print("CAMERA MODE -> DAY 4 FLASHBACK")

	if day4_flashback_music != null:
		day4_flashback_music.play()

	if day4_kitchen_ambience != null:
		day4_kitchen_ambience.play()

	await transition_layer.fade_in(0.7)

	print("DAY 4 FLASHBACK VISUAL ACTIVE")

	await play_day4_flashback_dialogue()

	await transition_layer.fade_out(0.7)

	if day4_flashback_music != null:
		day4_flashback_music.stop()

	if day4_kitchen_ambience != null:
		day4_kitchen_ambience.stop()

	day4_flashback.hide()

	psychiatrist_room.show()
	camera_director.switch_to_psychiatrist()

	await transition_layer.fade_in(0.7)

	print("========================")
	print("DAY 4 FLASHBACK")
	print("FLASHBACK FINISHED")
	print("========================")



func play_day4_flashback_dialogue() -> void:

	var dialogues := [

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "..."
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Aku sedang memasak"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "..."
		}
	]

	for dialog in dialogues:

		dialogue_manager.start_dialog(dialog)

		await dialogue_manager.dialogue_finished



func play_flashback() -> void:

	print("========================")
	print("DAY 6 FLASHBACK")
	print("FLASHBACK START")
	print("========================")

	flashback_kitchen.show()

	# Layar hitam sebelum berpindah ke flashback
	await transition_layer.fade_out(0.7)

	# Aktifkan kamera flashback
	flashback_camera.make_current()

	print("CAMERA MODE -> FLASHBACK")

	# Mulai ambience dan musik
	flashback_music.play()
	soup_sfx.play()
	kitchen_ambience.play()

	await transition_layer.fade_in(0.7)

	print("FLASHBACK VISUAL ACTIVE")

	# Mainkan dialog flashback
	await play_flashback_dialogue()

	# Setelah dialog selesai, kembali hitam
	await transition_layer.fade_out(0.7)

	# Matikan audio
	flashback_music.stop()
	soup_sfx.stop()
	kitchen_ambience.stop()

	# Sembunyikan environment flashback
	flashback_kitchen.hide()

	# Kembali ke ruang psikiater
	psychiatrist_room.show()
	camera_director.switch_to_psychiatrist()

	await transition_layer.fade_in(0.7)

	print("========================")
	print("DAY 6 FLASHBACK")
	print("FLASHBACK FINISHED")
	print("========================")



func hide_memory_objects() -> void:

	memory_apple.hide()
	memory_knife.hide()
	memory_meat.hide()


func show_memory_object(object: Node3D) -> void:

	hide_memory_objects()

	var original_scale := object.scale

	object.show()
	object.scale = Vector3.ZERO

	var tween := create_tween()

	tween.tween_property(
		object,
		"scale",
		original_scale,
		0.25
	)





func play_flashback_dialogue() -> void:

	var dialogues := [

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Dapurku"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Apa yang kau lakukan?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Memasak"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Untuk Siapa?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Mungkin pelanggan"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Apa kau mengenal mereka?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Tidak"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Sebenarnya apa yang kamu pikir ingin \"Mereka\" lakukan?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Bukankah semua orang datang untuk makan?"
		}
	]

	for dialog in dialogues:

		dialogue_manager.start_dialog(dialog)

		await dialogue_manager.dialogue_finished

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

		4:
			await play_day_4()

		6:
			await play_day_6()

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

	var dialogues := [

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

func play_day4_dialogue() -> void:

	var dialogues := [

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Hari ini kita coba menggunakan pendekatan yang berbeda."
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Kita tidak akan membahas dirimu."
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Tapi kita akan membahas \"Mereka\"."
		}
	]

	await play_dialogues(dialogues)

func play_day_4() -> void:

	print("========================")
	print("PSYCHIATRIST DAY 4")
	print("SEQUENCE START")
	print("========================")

	camera_director.switch_to_psychiatrist()

	await transition_layer.fade_in(0.7)

	# Dialog awal psikiater
	await play_day4_dialogue()

	# Flashback MC
	await play_day4_flashback()

	# Kembali ke ruang psikiater
	await play_day4_return_dialogue()

	print("========================")
	print("PSYCHIATRIST DAY 4")
	print("SEQUENCE FINISHED")
	print("========================")


func play_day4_return_dialogue() -> void:

	print("========================")
	print("DAY 4 RETURN DIALOGUE")
	print("SEQUENCE START")
	print("========================")

	var dialogues := [

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Apa yang barusan kamu ingat?"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Aku sedang memasak"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Coba ingat lagi"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Aku...."
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Sedang...."
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Membersihkan dapur"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Ceritamu berubah lagi"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Sebelumnya kau bilang makan malam"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Sekarang kau bilang memasak"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Lalu membersihkan dapur"
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Aku tidak mengerti"
		}
	]

	await play_dialogues(dialogues)

	print("========================")
	print("DAY 4 RETURN DIALOGUE")
	print("SEQUENCE FINISHED")
	print("========================")


func play_day_6() -> void:

	print("========================")
	print("PSYCHIATRIST DAY 6")
	print("SEQUENCE START")
	print("========================")

	# Kamera FPP psikiater
	camera_director.switch_to_psychiatrist()

	await transition_layer.fade_in(0.7)

	await play_day6_dialogue()

	await transition_layer.fade_out(0.7)

	print("========================")
	print("PSYCHIATRIST DAY 6")
	print("SEQUENCE FINISHED")
	print("========================")





func play_day6_dialogue() -> void:

	var intro_dialogues := [

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Selama beberapa bulan ini aku sudah mempelajari tentangmu"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Setidaknya aku sudah mencoba mengamati masa lalumu dan tentang \"mereka\""
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Hari ini aku ingin mencoba sesuatu yang berbeda lagi"
		},

		{
			"mode": "fullscreen",
			"speaker": "Psikiater",
			"text": "Tidak ada jawaban salah, aku hanya ingin kau menceritakan apa yang kau lihat"
		}
	]

	await play_dialogues(intro_dialogues)





	var question_1 := {
		"mode": "fullscreen",
		"speaker": "Psikiater",
		"text": "Apa yang kamu lihat?"
	}

	dialogue_manager.start_dialog(question_1)

	await dialogue_manager.dialogue_finished

	show_memory_object(memory_apple)

	var answer_1 := {
		"mode": "fullscreen",
		"speaker": "MC",
		"text": "Apel?"
	}

	dialogue_manager.start_dialog(answer_1)

	await dialogue_manager.dialogue_finished




	show_memory_object(memory_knife)

	var question_2 := {
		"mode": "fullscreen",
		"speaker": "Psikiater",
		"text": "Sekarang?"
	}

	dialogue_manager.start_dialog(question_2)

	await dialogue_manager.dialogue_finished

	var answer_2 := {
		"mode": "fullscreen",
		"speaker": "MC",
		"text": "Pisau?"
	}

	dialogue_manager.start_dialog(answer_2)

	await dialogue_manager.dialogue_finished




	show_memory_object(memory_meat)

	var question_3 := {
		"mode": "fullscreen",
		"speaker": "Psikiater",
		"text": "Sekarang apa yang kau lihat?"
	}

	dialogue_manager.start_dialog(question_3)

	await dialogue_manager.dialogue_finished

	var answer_3 := {
		"mode": "fullscreen",
		"speaker": "MC",
		"text": "Bagian daging sapi?"
	}

	dialogue_manager.start_dialog(answer_3)

	await dialogue_manager.dialogue_finished

	hide_memory_objects()

	await play_flashback()

	var final_dialogue := {
		"mode": "fullscreen",
		"speaker": "MC",
		"text": "........."
	}

	dialogue_manager.start_dialog(final_dialogue)

	await dialogue_manager.dialogue_finished





func play_dialogues(dialogues: Array) -> void:

	for dialogue in dialogues:

		print(
			"PSYCHIATRIST DIALOG -> ",
			dialogue["speaker"]
		)

		dialogue_manager.start_dialog(dialogue)

		await dialogue_manager.dialogue_finished

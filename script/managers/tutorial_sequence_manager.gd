class_name TutorialSequenceManager
extends Node

signal tutorial_started
signal tutorial_finished

@onready var dialogue_manager: DialogueManager = $"../DialogueManager"
@onready var transition_layer: TransitionLayer = $"../../UI/TransitionLayer"
@onready var camera_director: CameraDirector = $"../CameraDirector"

@onready var tutorial_police: Node3D = $"../../World/TutorialPolice"
@onready var tutorial_police_point: Marker3D = $"../../SpawnPoints/TutorialPolicePoint"

@onready var tutorial_menu: CanvasLayer = $"../../UI/TutorialMenu"


var active: bool = false
var burger_tutorial_active: bool = false





func play_tutorial() -> void:

	if active:
		return

	active = true

	print("========================")
	print("RESTAURANT TUTORIAL")
	print("TUTORIAL START")
	print("========================")

	tutorial_started.emit()

	await play_restaurant_intro()

	print("========================")
	print("RESTAURANT TUTORIAL")
	print("TUTORIAL SELESAI")
	print("========================")




func show_tutorial_menu() -> void:

	if tutorial_menu == null:
		print("TutorialMenu tidak ditemukan.")
		return

	tutorial_menu.show()

	print("========================")
	print("TUTORIAL MENU SHOW")
	print("========================")


func hide_tutorial_menu() -> void:

	if tutorial_menu == null:
		return

	tutorial_menu.hide()

func enter_restaurant() -> void:

	print("========================")
	print("ENTER RESTAURANT")
	print("========================")

	await transition_layer.fade_out(0.7)

	camera_director.switch_to_gameplay()

	tutorial_police.global_position = (
		tutorial_police_point.global_position
	)

	print("Tutorial Police Position : ", tutorial_police.global_position)
	print("Tutorial Police Point    : ", tutorial_police_point.global_position)

	tutorial_police.show()

	print("Tutorial Police Visible  : ", tutorial_police.visible)

	await transition_layer.fade_in(0.7)

	print("RESTAURANT TUTORIAL SCENE ACTIVE")


func play_restaurant_intro() -> void:

	await enter_restaurant()

	var dialogues := [

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Oke, karena restoran ini ada di pinggir kota maka restoran ini hanya menyediakan makanan-makanan basic tanpa tema tertentu."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Tujuannya memang untuk membuat pelanggan yang sedang berkunjung agar bisa mengisi perut mereka sebelum perjalanan panjang keluar kota."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Di sini ada beberapa menu utama yang bisa kamu sajikan."
		}
	]

	for dialogue in dialogues:

		dialogue_manager.start_dialog(dialogue)

		await dialogue_manager.dialogue_finished

	show_tutorial_menu()

	var final_dialogue := [

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Ada beberapa hal yang harus kamu perhatikan di dapur ini."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Waktu untuk menyelesaikan masing-masing menu makanan juga berbeda-beda."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Nasgor goreng dengan maksimal 60 detik."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Steak dengan maksimal 60 detik."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Salad dengan maksimal 40 detik."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Dan roti khas Lempuyangan dengan maksimal 40 detik."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Kemungkinan juga akan ada pelanggan yang memesan lebih dari satu menu."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Saat selesai mengambil bahan untuk membuat sebuah menu, setiap bahannya akan terceklist untuk menandakan progressmu dalam membuat sebuah menu."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Pelanggan adalah raja, kamu harus menjaga kualitas makanan atau minuman yang disajikan."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Mungkin itu saja hal yang harus kamu perhatikan."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Untuk sekarang tolong buatkan burger banggor dan bawakan soda untukku."
		}
	]

	for dialogue in final_dialogue:

		dialogue_manager.start_dialog(dialogue)

		await dialogue_manager.dialogue_finished

	await start_burger_tutorial()

func start_burger_tutorial() -> void:

	print("========================")
	print("BURGER TUTORIAL")
	print("START")
	print("========================")

	burger_tutorial_active = true

	hide_tutorial_menu()

	print("========================")
	print("TYPING BURGER DIMULAI")
	print("Tekan ENTER untuk menyelesaikan tutorial burger.")
	print("========================")

func _unhandled_input(event: InputEvent) -> void:

	if not burger_tutorial_active:
		return

	if event.is_action_pressed("ui_accept"):

		burger_tutorial_active = false

		print("========================")
		print("TYPING BURGER SELESAI")
		print("========================")

		await finish_burger_tutorial()

func finish_burger_tutorial() -> void:

	print("========================")
	print("BURGER TUTORIAL")
	print("FINISHED")
	print("========================")

	var dialogues := [

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Hmm, tidak buruk, sepertinya ada gunanya juga menunjukmu sebagai koki untuk restoran ini."
		},

		{
			"mode": "fullscreen",
			"speaker": "Polisi",
			"text": "Baiklah aku akan kembali dengan pekerjaanku, untuk sekarang tolong urus tempat ini dengan baik."
		},

		{
			"mode": "fullscreen",
			"speaker": "MC",
			"text": "Baik… Terimakasih"
		}
	]

	for dialogue in dialogues:

		dialogue_manager.start_dialog(dialogue)

		await dialogue_manager.dialogue_finished

	await police_leave_restaurant()


func police_leave_restaurant() -> void:

	print("========================")
	print("TUTORIAL POLICE LEAVING")
	print("========================")

	await transition_layer.fade_out(0.7)

	tutorial_police.hide()

	await transition_layer.fade_in(0.7)

	print("POLICE LEFT RESTAURANT")

	active = false

	tutorial_finished.emit()

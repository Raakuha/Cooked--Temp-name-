class_name EndingManager
extends Node

@onready var transition_layer: TransitionLayer = $"../../UI/TransitionLayer"
@onready var ending_door_audio: AudioStreamPlayer = $EndingDoorAudio
@onready var dialogue_manager: DialogueManager = $"../DialogueManager"
@onready var ending_screen: EndingScreen = $"../../UI/EndingScreen"

var ending_started: bool = false


func start_ending() -> void:

	if ending_started:
		return

	ending_started = true

	print("========================")
	print("ENDING START")
	print("========================")


	# =========================================
	# LAYAR MENJADI HITAM
	# =========================================

	await transition_layer.fade_out(1.0)


	# =========================================
	# SUARA PINTU RESTORAN
	# =========================================

	play_door_sound()


	# Beri sedikit jeda supaya suara pintu
	# terdengar sebelum dialog dimulai.

	await get_tree().create_timer(0.5).timeout


	# =========================================
	# DIALOG ENDING
	# =========================================

	await play_ending_dialogue()


	print("========================")
	print("ENDING DIALOGUE SELESAI")
	print("========================")
	
	await get_tree().create_timer(1.0).timeout
	ending_screen.show_ending()
	
	ending_started = false

func play_door_sound() -> void:

	print("========================")
	print("ENDING DOOR SOUND")
	print("========================")

	if ending_door_audio.stream == null:
		print("Door audio belum dipasang.")
		return

	ending_door_audio.play()

func play_ending_dialogue() -> void:

	print("========================")
	print("ENDING DIALOGUE START")
	print("========================")

	var dialogue_1 = {
		"mode": "fullscreen",
		"speaker": "MC",
		"text": "Selamat datang"
	}

	dialogue_manager.start_dialog(dialogue_1)

	await dialogue_manager.dialogue_finished


	var dialogue_2 = {
		"mode": "fullscreen",
		"speaker": "Mika",
		"text": "Halo paman, sekarang aku membawa beberapa temanku"
	}
	dialogue_manager.start_dialog(dialogue_2)

	await dialogue_manager.dialogue_finished


	print("========================")
	print("ENDING DIALOGUE FINISHED")
	print("========================")

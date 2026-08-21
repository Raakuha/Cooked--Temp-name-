class_name DayTransitionManager
extends Node

signal transition_started(day: int)
signal transition_finished(day: int)

@onready var transition_layer: TransitionLayer = $"../../UI/TransitionLayer"
@onready var profit_manager: ProfitManager = $"../ProfitManager"
@onready var customer_manager: CustomerManager = $"../CustomerManager"
@onready var day_manager: DayManager = $"../DayManager"
@onready var summary_ui: DaySummaryUI = $"../../UI/DaySummaryUI"
@onready var psychiatrist_sequence_manager : PsychiatristSequenceManager = $"../PsychiatristSequenceManager"

@onready var camera_director: CameraDirector = $"../CameraDirector"
@onready var dialogue_manager: DialogueManager = $"../DialogueManager"
@onready var player: Node3D = $"../../PlayerBaru"

var active: bool = false
var profit_dialogue_active: bool = false

func start_day_transition(completed_day: int) -> void:

	if active:
		return

	active = true

	print("========================")
	print("DAY TRANSITION")
	print("DAY ", completed_day, " SELESAI")
	print("========================")

	transition_started.emit(completed_day)

	await transition_layer.fade_out(0.7)

	var customers := customer_manager.get_customers_served()
	var profit := profit_manager.get_profit()

	summary_ui.show_summary(
		completed_day,
		customers,
		profit
	)

	active = false
	transition_finished.emit(completed_day)

func continue_to_next_day() -> void:

	if active:
		return

	active = true

	# =========================================
	# HILANGKAN SUMMARY
	# =========================================

	summary_ui.hide_summary()

	# =========================================
	# KEMBALI KE GAMEPLAY CAMERA
	# =========================================

	camera_director.switch_to_gameplay()

	# =========================================
	# TAMPILKAN MC DI DAPUR
	# =========================================

	await transition_layer.fade_in(0.7)

	# =========================================
	# PROFIT DIALOGUE
	# =========================================

	profit_dialogue_active = true

	await play_profit_dialogue()

	profit_dialogue_active = false

	# =========================================
	# KEMBALI KE LAYAR HITAM
	# =========================================

	await transition_layer.fade_out(0.7)

	# =========================================
	# RESET DATA HARI
	# =========================================

	customer_manager.reset_customer_count()
	profit_manager.reset_profit()

	# =========================================
	# SPECIAL SEQUENCE
	# =========================================

	if day_manager.current_day in [2, 4, 6]:

		await psychiatrist_sequence_manager.play_day_sequence(
			day_manager.current_day
		)

	# =========================================
	# LANJUT KE HARI BERIKUTNYA
	# =========================================

	day_manager.next_day()

	# =========================================
	# TAMPILKAN HARI BERIKUTNYA
	# =========================================

	await transition_layer.fade_in(0.7)

	active = false



func play_profit_dialogue() -> void:

	var profit := profit_manager.get_profit()

	print("========================")
	print("PROFIT DIALOGUE")
	print("Profit :", profit)
	print("========================")

	var selected_text: String = ""

	if profit > 0:

		var positive_dialogues := [
			"Tidak buruk juga",
			"Aku harus mempertahankannya",
			"Untuk sekarang aman..."
		]

		selected_text = positive_dialogues.pick_random()

	elif profit < 0:

		var negative_dialogues := [
			"Aku harus melakukan sesuatu",
			"Tidak bisa dibiarkan.......",
			"Kalau begini terus......"
		]

		selected_text = negative_dialogues.pick_random()

	else:

		selected_text = "Setidaknya aku masih bisa bertahan."

	print("Profit dialogue terpilih :", selected_text)

	var dialogue := {
		"mode": "bubble",
		"speaker_type": "mc",
		"speaker": "MC",
		"text": selected_text
	}

	var target: Node3D = player.get_node("DialogueMarker")

	dialogue_manager.start_dialog(
		dialogue,
		target
	)

	await dialogue_manager.dialogue_finished


#func continue_to_next_day() -> void:
#
	#if active:
		#return
#
	#summary_ui.hide_summary()
#
	#customer_manager.reset_customer_count()
	#profit_manager.reset_profit()
#
#
	## =========================================
	## SPECIAL SEQUENCE
	## =========================================
#
	#if day_manager.current_day in [2, 4, 6]:
#
		#await psychiatrist_sequence_manager.play_day_sequence(
			#day_manager.current_day
		#)
#
#
	## =========================================
	## KEMBALI KE RESTORAN
	## =========================================
#
	#await transition_layer.fade_in(0.7)
#
	#day_manager.next_day()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):

		if summary_ui.visible:
			continue_to_next_day()

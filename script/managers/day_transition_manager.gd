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

var active: bool = false


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

	summary_ui.hide_summary()

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
	# KEMBALI KE RESTORAN
	# =========================================

	await transition_layer.fade_in(0.7)

	day_manager.next_day()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):

		if summary_ui.visible:
			continue_to_next_day()
